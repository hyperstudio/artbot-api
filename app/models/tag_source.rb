class TagSource < ActiveRecord::Base
  validates :name, presence: true
  acts_as_tagger

  ALL_SOURCES = {
    'Stanford' => {
      'clean' => clean_stanford
    }
    'DBpedia' => {
      'clean' => clean_dbpedia
    }
    'OpenCalais' => {
      'clean' => clean_opencalais,
      'validate' => validate_opencalais,

      'entity_cutoffs' => {
        'Person' => 0.15,
        'Technology' => 0.1,
        'Movie' => 0.1,
        'IndustryTerm' => 0.1
      }
    }
  }

  def self.stanford
    find_or_create_by(name: 'Stanford')
  end

  def self.dbpedia
    find_or_create_by(name: 'DBpedia')
  end

  def self.calais
    find_or_create_by(name: 'OpenCalais')
  end

  def self.admin
    find_or_create_by(name: 'Admin')
  end

  def clean_dbpedia(ner_result)
      ner_result[:name] = ner_result.delete :label
      ner_result[:url] = ner_result.delete :uri
      if self.shares_word?(ner_result[:label], ner_result[:stanford_name])
          ner_result[:entity_type] = ner_result.delete :stanford_type
          ner_result[:tags] = ner_result.delete :categories.map{|cat| cat["label"]}
      else
          # treat the dbpedia mapping as erroneous, just use stanford
          ner_result.except!(:uri, :label, :description, :refcount, :categories)
          ner_result[:source_name] = :stanford
          self.stanford.clean(ner_result)
  end

  def validate_opencalais(ner_result)
    if ner_result[:type_group] == "topics"
      false
    elsif ner_result[:type_group] == "socialTag"
      true
    elsif ner_result[:type_group] == "entities"
      score_cutoff = ALL_SOURCES[name]['entity_cutoffs'][@entity.entity_type]
      if score_cutoff.present? and @entity.score >= score_cutoff
          true
      else
          false
      end
    end
  end

  def clean_opencalais(ner_result)
      ner_result[:url] = ner_result.delete :calais_id
      ner_result[:tags] = [ner_result[:name]] if ner_result[:type_group] == 'socialTag'
  end

  def clean_stanford(ner_result)
      ner_result[:name] = ner_result.delete :stanford_name
      ner_result[:entity_type] = ner_result.delete :stanford_type
  end

  def shares_word?(phrase1, phrase2)
      list1 = phrase1.split.map {|i| i.downcase}
      list2 = phrase2.split.map {|i| i.downcase}
      (list1 & list2).any?
  end

  def valid?(ner_result)
      ALL_SOURCES[name]['validate'](ner_result)
  end

  def clean(ner_result)
    ner_result[:source_name] = name
    if valid?(ner_result)
      ALL_SOURCES[name]['clean'](ner_result)
    end
  end
end
