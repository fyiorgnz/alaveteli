require 'aws-sdk-sqs'

class GetSQSMailLogs
  include Sidekiq::Worker

  def perform
    Aws.config.update({log_level: :warn})
    aws_log = MailServerLogDone.find_by(filename: 'aws-import.log')
    if aws_log == nil
      aws_log = MailServerLogDone.new(filename: 'aws-import.log')
    end
    aws_log.last_stat = Time.zone.now
    aws_log.save!

    order = aws_log.mail_server_logs.order("\"order\" DESC").first
    order = order == nil ? 1 : order.order + 1

    creds = Aws::Credentials.new((ENV['AWS_SQS_ACCESS_KEYID'] || 
                                  ENV['AWS_SES_ACCESS_KEYID']),
                                 (ENV['AWS_SQS_ACCESS_SECRET'] ||
                                  ENV['AWS_SES_ACCESS_SECRET']))
    sqs_client = Aws::SQS::Client.new(credentials: creds,
                                      region: (ENV['AWS_SQS_REGION'] || 
                                               'us-west-2'))

    queue_url = sqs_client.get_queue_url(queue_name: (ENV['AWS_SQS_QUEUE'] ||
                                   'agency-mail-notifications')).queue_url

    sqs_poller = Aws::SQS::QueuePoller.new(queue_url, client: sqs_client,
                                           max_number_of_messages: 1,
                                           idle_timeout: 5)

    sqs_poller.poll do |msg|
      begin
        sns_msg = JSON.load(msg.body)
        # TODO: Verify SNS Source
        ses_notif = JSON.load(sns_msg["Message"])
        request_addr_ary = MailServerLog.email_addresses_on_line(
          ses_notif["mail"]["headers"].select { |header| 
            header["name"] == "From" }.first["value"] )
        request_addr = request_addr_ary == nil ? nil : request_addr_ary[0]
        messageid_ary = ses_notif["mail"]["headers"].select { |header|
          header["name"] == "Message-ID" }.first["value"]
            .scan(/[^\s^<]+@[^\s^>]+/).sort.uniq
        messageid = messageid_ary == nil ? nil : messageid_ary[0]
        ir = InfoRequest.find_by_incoming_email(request_addr)
        if !ir
          STDOUT.puts("SQSPoller: Unable to find IR for #{request_addr} #{messageid}")
          throw :skip_delete
        end
        
        case ses_notif["eventType"]
        when "Delivery"
          dsn = "2.0.0"
          delivery = ses_notif["delivery"]
          delivery["recipients"].each do |recip|
            log = fake_syslog(delivery["timestamp"],
                              delivery["processingTimeMillis"]/1000,
                              delivery["reportingMTA"],
                              delivery["remoteMtaIp"],
                              recip, dsn,
                              delivery["smtpResponse"], "sent", messageid)
            if ir
              ir.mail_server_logs.create!(line: log, order: order,
                                               mail_server_log_done: aws_log)
              order = order + 1
              #msl.delivery_status = msl.line(:decorate => true).delivery_status
              #ir.save!
            end
          end
        when "Bounce"
          case sesmsg["bounce"]["bounceType"]
          when "Permanent"
            dsn = "5.0.0"
            status = "bounced"
          when "Transient"
            dsn = "4.0.0"
            status = "deferred"
          else
            dsn = "5.9.9"
            status = "unknown"
          end

          bounce = ses_notif["bounce"]
          bounce["recipients"].each do |recip|
            remoteMtaIp = bounce["remoteMtaIp"]  == nil ? "0.0.0.0" : bounce["remoteMtaIp"]
            reportingMTA = bounce["reportingMTA"] == nil ? "unknown" : bounce["reportingMTA"]
            dsn = recip["status"] == nil ? status : recip["status"]
            message = recip["diagnosticCode"] == nil ? "#{bounce["bounceType"]}/#{bounce["bounceSubtype"]}" : recip["diagnosticCode"]
            log = fake_syslog(bounce["timestamp"], 0, reportingMTA,
                              remoteMtaIp, recip["emailAddress"], dsn,
                              message, status, messageid)
           if ir
             ir.mail_server_logs.create!(line: log, order: order,
                                        mail_server_log_done: aws_log)
             #msl.delivery_status = msl.line(:decorate => true).delivery_status
             #ir.save!
             order = order + 1
           end
          end
        else
          STDOUT.puts("SQSPoller: Unknown event for #{request_addr} #{messageid} #{ses_notif["eventType"]}")
          throw :skip_delete
        end
      rescue Exception => e
        logger.debug "Ooops! #{e.message}: #{e.backtrace.inspect}"
        throw :skip_delete
      end
    end
  end

  def fake_syslog(timestamp, proctime, repmta, remotemta, toaddr, dsn,
                       message, status, messageid)
    syslog_ts = Time.iso8601(timestamp).strftime "%b %e %H:%M:%S"
    "#{syslog_ts} sessrv ses/smtpd[1]: 000000000: to: #{toaddr} (Message-ID: #{messageid}), relay=#{remotemta}, delay=#{proctime}, dsn=#{dsn}, status=#{status} (#{repmta}: #{message})"
  end
end
