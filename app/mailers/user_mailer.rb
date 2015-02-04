class UserMailer < ActionMailer::Base
    default template_path: 'mailers'

    def weekly_digest(user, recommended, ending_soon, favorite_events, favorite_exhibitions, **opts)
        @recommended = recommended
        @ending_soon = ending_soon
        @favorite_events = favorite_events
        @favorite_exhibitions = favorite_exhibitions
        headers = {
            to: user.email,
            template_name: 'weekly_update',
            subject: 'Artbot weekly digest'
        }.merge(opts)
        mail(headers)
    end

    def event_reminder(user, featured_event, upcoming_events, **opts)
        @featured_event = featured_event
        @upcoming_events = upcoming_events
        headers = {
            to: user.email,
            template_name: 'event_reminder',
            subject: "Don't miss " + featured_event.name
        }.merge(opts)
        mail(headers)
    end
end
