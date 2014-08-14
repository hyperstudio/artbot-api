class Interest < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag, class_name: ActsAsTaggableOn::Tag

  validate do |interest|
    if ! TagSource.admin.owned_tags.map(&:id).include?(tag_id)
      interest.errors.add(:tag_id, 'must be an admin-specified tag')
    end
  end
end
