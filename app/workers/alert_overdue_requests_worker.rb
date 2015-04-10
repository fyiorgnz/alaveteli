class AlertOverdueRequestsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    RequestMailer.alert_overdue_requests
  end
end
