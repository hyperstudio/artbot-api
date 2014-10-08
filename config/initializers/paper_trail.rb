DEFAULT_WHODUNNIT = 'scraper'
PaperTrail.whodunnit = DEFAULT_WHODUNNIT
Rails.application.config.paper_trail_default_whodunnit = DEFAULT_WHODUNNIT

module PaperTrail
    module Model
        def self.included(base)
            base.send :extend, ClassMethods
        end

        module InstanceMethods

          def current_user_is_bot?
            PaperTrail.whodunnit == DEFAULT_WHODUNNIT
          end

          def bot_overrode_admin?
            originator == 'scraper' && versions.where.not(whodunnit: DEFAULT_WHODUNNIT).present?
          end

          def revert_to_last_admin_change
            last_admin_version = versions.where.not(whodunnit: DEFAULT_WHODUNNIT).last
            self.whodunnit(last_admin_version.whodunnit) do
              self.update(last_admin_version.next.reify.attributes)
            end
          end

          def check_paper_trail
            last_bot_version = versions.where(whodunnit: DEFAULT_WHODUNNIT).last
            if last_bot_version.nil? || last_bot_version.next.nil? || last_bot_version.next.object.nil?
              return true
            else
              last_bot_version = last_bot_version.next.reify
            end
            equivalent_fields = attribute_names.map {|a| a.to_sym} - [:updated_at]
            equivalent_fields.each do |field|
              if send(field) != last_bot_version.send(field)
                return true
              end
            end
            false
          end
        end
    end
end
