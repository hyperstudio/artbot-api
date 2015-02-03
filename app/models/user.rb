class User < ActiveRecord::Base
  before_validation(:create_authentication_token, on: :create)

  has_many :favorites, dependent: :destroy
  has_many :events, through: :favorites
  has_many :interests, dependent: :destroy

  validates :authentication_token, uniqueness: true, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  def favorite_event_tags
    favorites.joins(event: [entities: [taggings: [:tag]]]).distinct('tags.id').pluck('tags.id')
  end

  def favorite_tags
    interests.pluck('tag_id')
  end

  # Override a Devise method
  # Default rememberable to true so we don't need a `remember_me` checkbox
  def remember_me
    true
  end

  def send_weekly_digest_email
    if send_weekly_emails
      suggested_events = prepare_weekly_email
      if suggested_events.present?
        mailer = UserMailer.weekly_digest(self, *suggested_events)
        mailer.deliver
      end
    end
  end

  def send_event_reminder_email
    if send_day_before_event_reminders
      closing_event = sniff_for_closing_event
      if closing_event.present?
        suggested_events = prepare_event_reminder_email(closing_event)
        mailer = UserMailer.event_reminder(self, *suggested_events)
        mailer.deliver
      end
    end
  end
  
  def prepare_event_reminder_email(event)
    used_ids = [event.id]
    other_events = Event.current.where.not(id: used_ids).order('end_date').take(2)
    [event, other_events]
  end

  private
  
  def prepare_weekly_email
    recommended = Event.recommended_for(self).take(2)
    used_ids = recommended.map {|r| r.id}

    ending_soon = Event.current.where.not(id: used_ids).order('end_date').take(2)
    used_ids += ending_soon.map {|r| r.id}

    favorites = events.current.where.not(id: used_ids)
    favorite_exhibitions = favorites.where(event_type: 'exhibition').order('end_date').take(2)
    favorite_events = favorites.where(event_type: 'event').order('end_date').take(2)

    unless recommended.empty? && ending_soon.empty?
      [recommended, ending_soon, favorite_exhibitions, favorite_events]
    end
  end
  
  def sniff_for_closing_event
    favorite_events = Event.ending_soon.order('end_date')
    if favorite_events.present?
      favorite_events.first
    end
  end

  def create_authentication_token
    self.authentication_token = loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
