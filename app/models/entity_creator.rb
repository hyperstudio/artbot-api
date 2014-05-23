class EntityCreator
    def initialize(ner_result)
        ner_result = ner_result.symbolize_keys!
        if ner_result[:uri].present? and self.shares_word?(ner_result[:label], ner_result[:stanford_name])
            @entity = Entity.find_or_initialize_by(url: ner_result[:uri])
            @entity.name = ner_result[:label]
            @entity.description = ner_result[:description]
            @entity.refcount = ner_result[:refcount]
            @categories = ner_result[:categories].map {|r| r.symbolize_keys}
        else
            @entity = Entity.find_or_initialize_by(stanford_name: ner_result[:stanford_name])
        end
        @entity.stanford_name = ner_result[:stanford_name]
        @entity.stanford_type = ner_result[:stanford_type]
    end
    
    def shares_word?(phrase1, phrase2)
        list1 = phrase1.split.map {|i| i.downcase}
        list2 = phrase2.split.map {|i| i.downcase}
        (list1 & list2).any?
    end

    def categories
        @categories
    end

    def entity
        @entity
    end

    def save
        @entity.save
    end
end