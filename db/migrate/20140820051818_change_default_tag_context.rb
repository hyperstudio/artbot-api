class ChangeDefaultTagContext < ActiveRecord::Migration
  class ActsAsTaggableOn::Tagging < ActiveRecord::Base
  end
  class TagContext < ActiveRecord::Base
  end

  def change
    ActsAsTaggableOn::Tagging.reset_column_information
    TagContext.reset_column_information

    def seed_contexts
        TagContext.create(name: 'movements')
        TagContext.create(name: 'eras')
        TagContext.create(name: 'regions')
    end

    reversible do |dir|
        dir.up do 
            seed_contexts
            ActsAsTaggableOn::Tagging.update_all context: 'movements'
        end
    end
  end
end
