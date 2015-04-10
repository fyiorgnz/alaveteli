class AlertCommentOnRequestsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    RequestMailer.alert_comment_on_request
  end
end
