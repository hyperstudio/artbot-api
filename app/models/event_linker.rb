class EventLinker
    def initialize(event)
        @event = event
        @tag_matches = {}
        @people_matches = {}
        @populated = false
    end

    def populate
        @event.case_insensitive_entities.includes(:events, taggings: [:tag]).each do |entity|
            # Check for any events directly related by people
            related_events_by_entity = entity.events.select {|e| valid_event?(e)}
            if related_events_by_entity.any? && entity.entity_type == 'person'
                add_people_match(entity, related_events_by_entity)
            end
            # Add all of the entity's tags to a master list
            # Include the tagging for scoring purposes
            entity.taggings.map {|tagging| add_tag_match(tagging)}
        end
        # Now get all the tag-related events in a single query
        related_events_by_tag.each do |related_event|
            tags_for(related_event).map {|tag_id| add_event_to_tag_match(tag_id, related_event)}
        end

        @populated = true
    end

    def related_events_by_tag
        Event.current.matching_tags(@tag_matches.keys).where.not(id: @event.id).includes(entities: [taggings: [:tag]])
    end

    def tags_for(related_event)
        related_event.entities.map {|entity| entity.taggings.map {|tagging| tagging.tag.id}}.flatten.uniq
    end

    def add_people_match(entity, events)
        if @people_matches.key?(entity.name)
            @people_matches[entity.name][:events] += events
        else
            @people_matches[entity.name] = {tag: entity, events: events, score: 0}
        end
    end

    def add_tag_match(tagging)
        @tag_matches[tagging.tag.id] = {tag: tagging.tag, tagging: tagging, events: [], score: 0}
    end

    def add_event_to_tag_match(tag_id, event)
        @tag_matches[tag_id][:events] << event
    end

    def valid_event?(other_event)
        other_event.id != @event.id && (other_event.end_date.nil? || other_event.end_date >= Time.now())
    end

    def score_result(result)
        tagging = result.delete(:tagging)
        score = 0
        if tagging.nil?
          # It's an entity, so downgrade it
          score -= 100
        elsif tagging.tagger_id == 5
          # It's an admin tag, so upgrade it
          score += 100
        end
        # More events is a proxy for a less targeted recommendation
        # use it as a tiebreaker
        num_events = result[:events].count
        score -= num_events
        if num_events < 2
            # It only has 1 related event so deprioritize it.
            score -= 5
        end
        result[:score] = score
        result
    end

    def get_results
        if !@populated
            populate
        end
        (@tag_matches.values + @people_matches.values).select {|result| result[:events].any?}.uniq
    end

    def get_scored_results(limit=5)
        get_results.map {|result| score_result(result)}
                   .sort {|x,y| y[:score] <=> x[:score]}
                   .take(limit)
                   .map {|result| limit_events(result, 6)}
                   .map {|result| serialize_events(result)}
    end

    def limit_events(result, count)
        result[:events] = result[:events].take(count)
        result
    end

    def serialize_events(result)
        result[:events] = result[:events].map {|event| EventSerializer.new(event).as_json[:event]}
        result
    end
end