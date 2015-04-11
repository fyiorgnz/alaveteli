class ProcessS3MailWorker
  include Sidekiq::Worker

  def perform
    connection = Fog::Storage.new({
      provider: 'AWS',
      region: ENV['AWS_REGION'],
      aws_access_key_id: ENV['AWS_ACCESS_KEY'],
      aws_secret_access_key: ENV['AWS_SECRET_KEY']
    })

    incoming_bucket = connection.directories.get(ENV['INCOMING_BUCKET'])
    processed_bucket = connection.directories.get(ENV['PROCESSED_BUCKET'])

    incoming_bucket.files.each do |file|
      puts "got #{file.key}"

      body, key = file.body, file.key
      RequestMailer.receive(body)

      processed_bucket.files.create key: key, body: body

      file.destroy
    end

  end
end
