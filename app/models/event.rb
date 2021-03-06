class Event < ActiveRecord::Base
  validates :name, presence: true
  validates :url, uniqueness: true
  belongs_to :location
  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites
  has_and_belongs_to_many :entities

  delegate :name, to: :location, prefix: true
  before_create :process_dates

  has_paper_trail :skip => [:favorites, :users, :entities]
  before_update :check_paper_trail, :if => :current_user_is_bot?
  after_commit :revert_to_last_admin_change, :if => :bot_overrode_admin?, on: :update

  has_attached_file :image,
    default_format: :jpg,
    default_url: lambda {|attachment| attachment.instance.location_image},
    styles: {
      small: "200x200>",
      large: "600x600>",
      email: "564x376"
    },
    convert_options: {
      email: "-scale '564x376^' -background '#3b3b3b' -gravity center -extent 564x376 -quality 60"
    }
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  @@blacklisted_urls = [
    "harvardartmuseums.org/visit/calendar/student-guide-tour-",
    "harvardartmuseums.org/visit/calendar/materials-lab-plaster-workshop-",
    "harvardartmuseums.org/visit/calendar/midday-organ-recital",
    "harvardartmuseums.org/visit/calendar/members-collections-tour",
    "harvardartmuseums.org/visit/calendar/arts-first-at-the-harvard-art-museums-harvard-student-production-of-john-"
  ]

  def blacklisted?
    @@blacklisted_urls.map {|u| url.include? u}.any?
  end

  def process_dates
    dates = DateParser.parse(self.dates)

    if dates[0].nil? && dates[1].nil?
      # Assume it's an exhibition and give it default dates
      start_date = Time.now.midnight
      end_date = start_date + 1.year
    elsif dates[0].nil?
      # Probably shouldn't happen
      start_date = Time.now.midnight
      end_date = dates[1].midnight
    elsif dates[1].nil?
      # Assume it's an event and default to ending in 1 day
      start_date = dates[0]
      end_date = start_date + 1.day - 1.second
    else
      start_date = dates[0]
      end_date = dates[1]
    end

    if self.start_date.nil?
      self.start_date = start_date
    end
    if self.end_date.nil?
      self.end_date = end_date
    end

    if self.end_date - self.start_date <= 3.days
      self.event_type = 'event'
    else
      self.event_type = 'exhibition'
    end
  end

  def self.recommended_for(user)
    recommended_events = current.
      matching_tags(user.favorite_tags + user.favorite_event_tags).
      not_favorited_by(user)
    if recommended_events.empty?
      recommended_events = current
    end
    recommended_events.order(:end_date)
  end

  def self.for_date(year, month, day)
    result = all
    if day.present?
      start_of_range = Date.new(year.to_i, month.to_i, day.to_i)
      end_of_range = start_of_range + 1.day
    elsif month.present?
      start_of_range = Date.new(year.to_i, month.to_i, 1)
      end_of_range = start_of_range + 1.month
    elsif year.present?
      start_of_range = Date.new(year.to_i, 1, 1)
      end_of_range = start_of_range + 1.year
    else
      start_of_range = nil
      end_of_range = nil
    end
    if start_of_range.present? && end_of_range.present?
      result = result.where('start_date < ? AND end_date >= ?', end_of_range, start_of_range)
    end
    result.order(:end_date)
  end

  def self.newest(count)
    order('created_at DESC').limit(count)
  end

  def self.current
    where('end_date >= ? AND start_date <= ?', Time.now, Time.now + 1.month)
  end

  def self.matching_tags(tag_ids)
    joins(entities: [taggings: [:tag]]).where('tags.id IN (?)', tag_ids).distinct
  end

  def self.favorited_by(user)
    where(id: user.favorites.pluck('event_id'))
  end

  def self.not_favorited_by(user)
    where.not(id: user.favorites.pluck('event_id'))
  end

  def self.by_distance(latitude, longitude, radius=10)
    if latitude.present? and longitude.present?
      locations = Location.near([latitude, longitude], radius, :order => nil).pluck('id')
      where(location_id: locations)
    else
      all
    end
  end

  def self.ending_soon
    event_cutoff = Time.now.utc.midnight + 3.days
    exhibition_cutoff = Time.now.utc.midnight + 7.days
    where('(end_date >= ? AND end_date <= ? AND event_type = ?) OR (end_date >= ? AND end_date <= ? AND event_type = ?)',
      event_cutoff, event_cutoff+1.day, 'event', exhibition_cutoff, exhibition_cutoff+1.day, 'exhibition')
  end

  def tags(context: nil, source: nil)
    scope = ActsAsTaggableOn::Tag.joins(:taggings).where(
      'taggings.taggable_type = ? AND taggings.taggable_id IN (?)',
      'Entity', case_insensitive_entities.pluck('id')).distinct
    if !context.nil?
      scope = scope.where('taggings.context = ?', context.to_s.pluralize)
    end
    if !source.nil?
      scope = scope.where('taggings.tagger_id = ?', source.id)
    end
    scope.distinct
  end
  
  def admin_tags
    tags(source: TagSource.admin)
  end

  def tag_list
    case_insensitive_entities.joins(taggings: [:tag]).distinct('tags.name').pluck('tags.name').join(', ')
  end

  def admin_tag_list
    case_insensitive_entities.joins(taggings: [:tag]).where(
      'taggings.tagger_id = ?', TagSource.admin.id).distinct('tags.name').pluck('tags.name').join(', ')
  end

  def related_events
    EventLinker.new(self).get_scored_results
  end

  def case_insensitive_entities
    Entity.where('lower(entities.name) IN (?)', entities.pluck('name').map{|e| e.downcase})
  end

  def case_insensitive_admin_entities
    case_insensitive_entities.joins(:taggings).where('taggings.tagger_id = ?', TagSource.admin.id)
  end

  def payload
    name + " " + description
  end

  def fetch_entities(path)
    NerQuerier.new(path).parsed_query(payload)
  end

  def get_and_process_entities(ner_path)
    fetch_entities(ner_path).each do |entity_result|
      entity = EntityCreator.new(entity_result).create

      entity.add_event(self)
      # This might be redundant but it gets case-insensitive admin matches
      case_insensitive_admin_entities.distinct.map {|admin_entity| admin_entity.add_event(self)}
    end
  end

  def truncated_description(max_word_length=25)
    if description.present?
      descrip = description.split(' ')[0..max_word_length].join(' ') + '...'
      descrip.gsub('<br/><br/>', ' ')
    else
      ''
    end
  end

  def location_image
    location.present? ? location.image.url : "http://#{ENV['ARTBOT_CDN_HOST']}/3b3b3b.png"
  end
end
