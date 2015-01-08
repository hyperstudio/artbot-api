require 'spec_helper'

feature 'User requests to the admin page' do

    scenario 'and is a valid admin user' do
        password = 'fakepassword'
        user = create(:user, 
            email: 'foo@example.com', 
            password: password, 
            admin: true)

        visit '/admin'

        fill_in "user_email", :with => user.email
        fill_in "user_password", :with => user.password
        click_button "Sign in"

        expect(page).to have_text('Signed in successfully')
        expect(page).to have_text('Dashboard')
    end

    scenario 'and is not a valid admin user' do
        password = 'fakepassword'
        user = create(:user, 
            email: 'foo@example.com', 
            password: password, 
            admin: false)

        visit '/admin'

        fill_in "user_email", :with => user.email
        fill_in "user_password", :with => user.password
        click_button "Sign in"

        expect(page).to have_text('Signed in successfully')
        expect(page).to have_text('Artbot RESTful Web API Examples')
    end
end