ActiveAdmin.register PaperTrail::Version, as: "Version" do
    show do
        attributes_table do
            row :id
            row :item
            row :whodunnit
            row :object do |version|
                old_version = version.reify
                if old_version.present?
                    version.reify.attributes.map {|k,v| 
                        "<strong>%s:</strong> %s" % [k.to_s.upcase, v.to_s]
                        }.join('<br/><br/>').html_safe
                else
                    ""
                end
            end
            row :created_at
            row :item_type
            row :event
        end
    end
end