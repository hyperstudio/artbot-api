ActiveAdmin.register_page "Event Links" do
    sidebar :filters do
        form do |f|
            f.input 'Search events', :type => :text, :name => :event_search
            br
            f.input 'Search tags', :type => :text, :name => :tag_search
            br
            text_node 'Tag type'
            br
            f.input 'All', :type => :radio, :name => :tag_type, :value => :all, :checked => :checked
            br
            f.input 'Admin', :type => :radio, :name => :tag_type, :value => :admin
            br
            f.input 'Other', :type => :radio, :name => :tag_type, :value => :other
            br
            f.input '', :type => :submit
        end
    end

    controller do
        def filtered_events
            query = Event
            if params.include?(:event_search)
                event_search = params[:event_search].downcase
                query = query.where('lower(events.name) LIKE :search', 
                    {:search => "#{event_search}%"})
            end
            if params.include?(:tag_search)
                tag_search = params[:tag_search].downcase
                query = query.joins(entities: [taggings: [:tag]]).where(
                    'lower(tags.name) LIKE :search',
                    {:search => "#{tag_search}%"})
            end
            if params[:tag_type] == 'admin'
                query = query.joins(entities: [:taggings]).where(
                    'taggings.tagger_id = ?', 5)
            elsif params[:tag_type] == 'other'
                query = query.joins(entities: [:taggings]).where.not(
                    'taggings.tagger_id = ?', 5)
            end
            query.distinct
        end
    end

    content do
        events = controller.filtered_events.page(params[:page]).per(10)
        paginated_collection events do
            table do
                events.each do |event|
                    params_hash = {
                        :admin_tags => [],
                        :tags => [],
                        :entities => []
                    }
                    results = event.related_events
                    results.each do |result|
                        if result[:score] < -50
                            params_hash[:entities] << result
                        elsif (-50..50).include?(result[:score])
                            params_hash[:tags] << result
                        elsif result[:score] >= 50
                            params_hash[:admin_tags] << result
                        end
                    end

                    name_empty = true

                    params_hash.each do |tag_type, results|
                        tag_type_empty = true
                        

                        results.each do |result|
                            tag = result[:tag]
                            matching_events = result[:events]

                            tag_empty = true

                            if name_empty
                                tr td h3 strong link_to event.name, admin_event_path(event.id), :target => :blank
                                name_empty = false
                            end
                            if tag_type_empty
                                tr td h5 strong tag_type.upcase
                                tag_type_empty = false
                            end
                            tr do
                                if tag_empty
                                    td strong link_to tag.name, admin_tag_path(tag.id), :target => :blank
                                    tag_empty = false
                                else
                                    td ''
                                end

                                if matching_events.empty?
                                    td ''
                                end
                                matching_events.each_with_index do |matching_event, index|
                                    if index == 0
                                        td link_to matching_event.name, admin_event_path(matching_event.id)
                                    else
                                        tr do
                                            td ''
                                            td link_to matching_event.name, admin_event_path(matching_event.id)
                                        end
                                    end
                                end
                            end
                        end
                        tr td h1 ''
                    end
                    tr td h1 ''
                end
            end
        end
    end
end