# Put dev images in a separate folder so they don't overlap
if Rails.env.test?
    Paperclip::Attachment.default_options[:path] = '#{Rails.root}/spec/test_files/:class/:id.:style.:extension'
else
    startpath = ''
    startpath += 'dev/' if Rails.env.development?
    Paperclip::Attachment.default_options.merge!({
        :storage => :s3,
        :url => ':s3_domain_url',
        :path => startpath + ':class/:id.:style.:extension',
        :s3_credentials => {
            :bucket => ENV['S3_BUCKET_NAME'],
            :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
            :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
        }
    })
end
