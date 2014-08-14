module AdminOwnedTagHelpers
  def create_admin_owned_tags(tag_list)
    admin_tag_source = create(:tag_source, name: 'Admin')
    entity = create(:entity)
    admin_tag_source.tag(entity, with: tag_list, on: :genres)
  end
end
