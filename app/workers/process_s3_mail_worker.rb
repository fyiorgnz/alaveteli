class ProcessS3MailWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(15) }

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

      body = file.body
      message = Mail.new body

      if message.to.any? { |m| m =~ /^fyi-request/ }
        puts 'DRY RUN'
        puts message.from
        # RequestMailer.receive(body)
      end

      processed_bucket.create key: file.key, body: body

      # commented out for dry run
      # file.destroy
    end

  end
end
