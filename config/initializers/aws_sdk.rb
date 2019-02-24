if (ENV['AWS_SES_ACCESS_KEYID'] && ENV['AWS_SES_ACCESS_SECRET'])
  creds = Aws::Credentials.new(ENV['AWS_SES_ACCESS_KEYID'], ENV['AWS_SES_ACCESS_SECRET'])
  Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: creds, region: ENV['AWS_SES_REGION'] || 'us-east-1')
end
