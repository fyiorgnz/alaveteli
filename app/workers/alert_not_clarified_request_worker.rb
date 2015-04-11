class AlertNotClarifiedRequestsWorker
  include Sidekiq::Worker

  def perform
    RequestMailer.alert_not_clarified_request
  end
end
