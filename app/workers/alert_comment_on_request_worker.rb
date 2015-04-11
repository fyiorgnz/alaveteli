class AlertCommentOnRequestsWorker
  include Sidekiq::Worker

  def perform
    RequestMailer.alert_comment_on_request
  end
end
