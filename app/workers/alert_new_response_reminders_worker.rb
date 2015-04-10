class AlertOverdueRequestsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    RequestMailer.alert_new_response_reminders
  end
end
