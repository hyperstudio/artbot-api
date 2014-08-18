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
                    admin_tags = event.admin_tags
                    other_tags = event.tags.where.not(id: admin_tags.pluck('id')).order('name')
                    params_hash = {
                        :admin_tags => admin_tags,
                        :tags => other_tags
                    }
                    admin_empty = params_hash[:admin_tags].empty?
                    other_empty = params_hash[:tags].empty?

                    if params[:tag_type] == 'admin'
                        if admin_empty
                            break
                        end
                        params_hash[:tags] = []
                    elsif params[:tag_type] == 'other'
                        if other_empty
                            break
                        end
                        params_hash[:admin_tags] = []
                    else
                        if admin_empty && other_empty
                            break
                        end
                    end

                    name_empty = true

                    params_hash.each do |tag_type, tags|
                        tag_type_empty = true
                        

                        tags.each do |tag|
                            tag_empty = true

                            if name_empty
                                tr td h3 strong link_to event.name, admin_event_path(event.id)
                                name_empty = false
                            end
                            if tag_type_empty
                                tr td h5 strong tag_type.upcase
                                tag_type_empty = false
                            end
                            tr do
                                if tag_empty
                                    td strong link_to tag.name, admin_tag_path(tag.id)
                                    tag_empty = false
                                else
                                    td ''
                                end
                                matching_events = Event.matching_tags([tag.id]).where.not(id: event.id)
                                if matching_events.empty?
                                    td ''
                                end
                                matching_events.to_a.each_with_index do |matching_event, index|
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