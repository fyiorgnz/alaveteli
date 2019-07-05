require 'aws-sdk-s3'

class ProcessS3MailWorker
  include Sidekiq::Worker

  def perform
    Aws.config.update({log_level: :warn})
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
    s3_client = Aws::S3::Client.new(credentials: creds,
                                    region: ENV['AWS_REGION'])
    in_bucket = ENV['INCOMING_BUCKET']
    done_bucket = ENV['PROCESSED_BUCKET']

    begin
      s3_client.head_bucket({bucket: in_bucket})
      s3_client.head_bucket({bucket: done_bucket})
    rescue Aws::S3::Errors::NotFound
      puts "Bucket(s) not found"
    else
      objlst = s3_client.list_objects_v2({bucket: in_bucket})
      objlst.contents.each{ |objectitem|
        # Retrieve incoming e-mail and process via RM.
        obj = s3_client.get_object({bucket: in_bucket, key: objectitem.key})
	RequestMailer.receive(obj.body.read)

        # Archive message
	s3_client.copy_object({
          bucket: done_bucket,
          copy_source: "/#{in_bucket}/#{objectitem.key}",
          key: objectitem.key,
        })

        # Remove old e-mail from incoming bucket
        s3_client.delete_object({bucket: in_bucket, key: objectitem.key})
      }
    end
  end
end
