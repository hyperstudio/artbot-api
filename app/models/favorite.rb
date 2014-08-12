class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  validates :user, presence: true
  validates :event, presence: true

  def self.for_past_events
    joins(:event).where('events.end_date < now()').order('end_date desc')
  end
end
