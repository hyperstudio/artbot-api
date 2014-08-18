ActiveAdmin.register_page "Event Links" do
    sidebar :hello do
        h3 'Filters'
        ul do
            li 'Hello world'
        end
    end

    content do
      table do
        tr do
            td strong 'ADMIN TAGS'
        end
        Event.all.each do |event|
            event_empty = true
            event.admin_tags.each do |admin_tag|
                tag_empty = true
                Event.matching_tags([admin_tag.id]).where.not(id: event.id).each do |matching_event|
                    tr do
                        if event_empty
                            td link_to event.name, admin_event_path(event.id)
                            event_empty = false
                        else
                            td ''
                        end
                        if tag_empty
                            td link_to admin_tag.name, admin_tag_path(admin_tag.id)
                            tag_empty = false
                        else
                            td ''
                        end
                        td link_to matching_event.name, admin_event_path(matching_event.id)
                    end
                end
            end
        end
      end
    end
end