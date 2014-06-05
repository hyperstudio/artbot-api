class TagSource < ActiveRecord::Base
  validates :name, presence: true
  has_and_belongs_to_many :entities
  acts_as_tagger

  OPENCALAIS_ENTITY_CUTOFFS = {
      'Person' => 0.15,
      'Technology' => 0.1,
      'Movie' => 0.1,
      'IndustryTerm' => 0.1
  }

  def self.insensitive_find(path)
    where("lower(name) = ?", path.downcase).first
  end

  def self.stanford
    find_or_create_by(name: 'Stanford')
  end

  def self.dbpedia
    find_or_create_by(name: 'DBpedia')
  end

  def self.opencalais
    find_or_create_by(name: 'OpenCalais')
  end

  def self.zemanta
    find_or_create_by(name: 'Zemanta')
  end

  def self.admin
    find_or_create_by(name: 'Admin')
  end

  def clean_dbpedia(ner_result)
      # Clean of any trailing parens (e.g. "William Wegman (photographer)")
      name = ner_result.delete :label
      name = name.include?("(") ? name.split("(")[0].strip : name
      ner_result[:name] = name
      ner_result[:url] = ner_result.delete :uri
      ner_result[:entity_type] = ner_result.delete :stanford_type
      if self.shares_word?(ner_result[:name], ner_result[:stanford_name])
          ner_result[:tags] = (ner_result.delete :categories).map{|cat| cat[:label]}
      else
          # treat the dbpedia mapping as erroneous, just use stanford
          ner_result.except!(:url, :name, :description, :refCount, :categories)
          ner_result[:name] = ner_result.delete :stanford_name
          ner_result[:source] = TagSource.stanford
      end
      ner_result
  end

  def validate_opencalais(ner_result)
    if ner_result[:type_group] == "topics"
      false
    elsif ner_result[:type_group] == "socialTag"
      true
    elsif ner_result[:type_group] == "entities"
      score_cutoff = OPENCALAIS_ENTITY_CUTOFFS[ner_result[:entity_type]]
      if score_cutoff.present? and ner_result[:score] >= score_cutoff
          true
      else
          false
      end
    end
  end

  def clean_opencalais(ner_result)
      ner_result[:url] = ner_result.delete :calais_id
      ner_result[:tags] = [ner_result[:name]] if ner_result[:type_group] == 'socialTag'
      ner_result[:entity_type].downcase!
      ner_result
  end

  def clean_stanford(ner_result)
      ner_result[:name] = ner_result.delete :stanford_name
      ner_result[:entity_type] = ner_result.delete :stanford_type
      ner_result
  end

  def best_zemanta_url(ner_targets)
      best_url = ""
      order_preference = ['dbpedia.org', 'freebase.com', 'musicbrainz.org', 'wikipedia']
      order_preference.each do |flag|
          preferred_target = ner_targets.select {|t| t.include? flag}
          if preferred_target.length > 0
            best_url = preferred_target.first
            break
          end
      end
      if best_url.empty?
          best_url = ner_targets.first
      end
      best_url
  end

  def validate_zemanta(ner_result)
      if ner_result[:entity_type].present? and !ner_result[:entity_type].start_with?('/people')
        false
      else
        true
      end
  end

  def clean_zemanta(ner_result)
      ner_result[:url] = best_zemanta_url(ner_result[:targets].split(', '))
      ner_result[:name] = ner_result.delete :anchor
      ner_result[:score] = ner_result.delete :relevance
      ner_result[:tags] = ner_result[:entity_type].present? ? [] : [ner_result[:name]]
      ner_result[:entity_type] = ner_result[:entity_type].split('/').pop
      ner_result.except!(:confidence, :targets)
      ner_result
  end

  def shares_word?(phrase1, phrase2)
      list1 = phrase1.split.map {|i| i.downcase}
      list2 = phrase2.split.map {|i| i.downcase}
      (list1 & list2).any?
  end

  def is_valid?(ner_result)
      method_name = 'validate_%s' % name.downcase
      if self.respond_to? method_name
        self.send(method_name, ner_result)
      else
        true
      end
  end

  def clean(ner_result)
    if is_valid?(ner_result)
      method_name = 'clean_%s' % name.downcase
      if self.respond_to? method_name
        self.send(method_name, ner_result)
      else
        ner_result
      end
    end
  end
end
