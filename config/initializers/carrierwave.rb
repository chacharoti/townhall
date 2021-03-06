CarrierWave.configure do |config|
  if Rails.env.development? || Rails.env.test?
    config.storage = :file
  else
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],                        # required
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region:                ENV['S3_REGION'] # Change this for different AWS region. Default is 'us-east-1'
    }
    config.fog_directory  = ENV['S3_BUCKET_NAME']
    config.storage = :fog
  end
end
