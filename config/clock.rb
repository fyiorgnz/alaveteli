require_relative 'boot'
require_relative 'environment'

module Clockwork
  handler {}

  every(10.minutes, 'alert_tracks') { AlertTracksWorker.perform_async }
  every(10.minutes, 'send_batch_requests') { SendBatchRequestsWorker.perform_async }
  every(10.minutes, 'process_s3_mail') { ProcessS3MailWorker.perform_async }

  every(5.minutes, 'update_xapian_index') { UpdateXapianIndexWorker.perform_async }

  every(1.hour, 'alert_comment_on_requests') { AlertCommentOnRequestsWorker.perform_async }

  every(1.day, 'delete_old_things') { DeleteOldThingsWorker.perform_async }
  every(1.day, 'alert_over_due_requests') { AlertOverdueRequestsWorker.perform_async }
  every(1.day, 'alert_not_clarified_requests') { AlertNotClarifiedRequestsWorker.perform_async }
  every(1.day, 'alert_not_clarified_request') { AlertOverdueRequestsWorker.perform_async }
  every(1.day, 'stop_new_responses_on_old_requests') { StopNewResponsesOnOldRequestsWorker.perform_async }

  every(1.day, 'update_public_bodies_stats') { UpdatePublicBodyStatsWorker.perform_async }
end
