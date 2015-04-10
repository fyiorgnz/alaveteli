class AlertNotClarifiedRequestsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    RequestMailer.alert_not_clarified_request
  end
end
