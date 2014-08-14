require 'spec_helper'

feature 'User manages interests', js: true do
  include CurbHelpers
  include AdminOwnedTagHelpers

  scenario 'by adding one' do
    user = create(:user)
    create_admin_owned_tags('foo, bar')
    tag = ActsAsTaggableOn::Tag.find_by(name: 'foo')

    curb = post_to_api(
      '/interests',
      {
        authentication_token: user.authentication_token,
        tag_id: tag.id
      }
    )
    json_response = parse_response_from(curb)

    expect(json_response['interest']['tag']['id']).to eq tag.id
  end

  scenario 'by requesting my current interests' do
    user = create(:user)
    create_admin_owned_tags('foo, bar')
    tag_of_interest = ActsAsTaggableOn::Tag.find_by(name: 'foo')
    tag_of_disinterest = ActsAsTaggableOn::Tag.find_by(name: 'bar')

    interest = create(:interest, user: user, tag: tag_of_interest)

    curb = get_from_api(
      '/interests',
      {
        authentication_token: user.authentication_token,
      }
    )
    json_response = parse_response_from(curb)
    tag_ids = json_response['interests'].map{ |interest| interest['tag']['id'] }

    expect(tag_ids).to include(tag_of_interest.id)
    expect(tag_ids).not_to include(tag_of_disinterest.id)
  end

  scenario 'by removing one' do
    user = create(:user)
    create_admin_owned_tags('foo, bar')
    tag_of_interest = ActsAsTaggableOn::Tag.find_by(name: 'foo')
    interest = create(:interest, user: user, tag: tag_of_interest)

    curb = delete_via_api(
      "/interests/#{interest.id}",
      { authentication_token: user.authentication_token }
    )

    expect(curb.response_code).to eq 204
  end

  scenario 'by requesting a list of possible interests' do
    tags = %w|foo bar baz|
    create_admin_owned_tags(tags.join(','))
    non_admin_tag = create(:tag, name: 'Nope')

    curb = get_from_api('/possible_interests')

    json_response = parse_response_from(curb)
    json_tag_names = json_response['tags'].map { |tag| tag['name'] }

    expect(json_tag_names).to match_array(tags)
    expect(json_tag_names).not_to include(non_admin_tag.name)
  end
end
