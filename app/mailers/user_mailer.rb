class UserMailer < ActionMailer::Base
    default template_path: 'mailers'

    def weekly_digest(user, recommended, ending_soon, favorite_events, favorite_exhibitions)
        @recommended = recommended
        @ending_soon = ending_soon
        @favorite_events = favorite_events
        @favorite_exhibitions = favorite_exhibitions
        mail(
            :to => user.email,
            :template_name => 'weekly_update',
            :subject => 'Artbot weekly digest'
        )
    end
end
