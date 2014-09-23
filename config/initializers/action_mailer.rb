module Artx
    class Application < Rails::Application
        config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"
        config.action_mailer.default_options = {
            charset: 'utf-8',
            from: '"Artbot" <%s>' % ENV['MANDRILL_USERNAME']
        }

        config.action_mailer.perform_deliveries = true
        config.action_mailer.raise_delivery_errors = true
        config.action_mailer.delivery_method = :smtp
        config.action_mailer.smtp_settings = {
            :address =>                 'smtp.mandrillapp.com',
            :domain =>                  'heroku.com',
            :port =>                    '587',
            :user_name =>               ENV['MANDRILL_USERNAME'],
            :password =>                ENV['MANDRILL_APIKEY'],
            :authentication =>          :plain,
            :enable_starttls_auto =>    true
        }
    end
end