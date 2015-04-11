class AlertOverdueRequestsWorker
  include Sidekiq::Worker

  def perform
    RequestMailer.alert_overdue_requests
  end
end
