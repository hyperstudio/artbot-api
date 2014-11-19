# Put dev images in a separate folder so they don't overlap
if Rails.env.test?
    startpath = '#{Rails.root}/spec/test_files/'
elsif Rails.env.development?
    startpath = 'dev/'
else
    startpath = ''
end

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
