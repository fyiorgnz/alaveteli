class AlertOverdueRequestsWorker
  include Sidekiq::Worker

  def perform
    RequestMailer.alert_new_response_reminders
  end
end
