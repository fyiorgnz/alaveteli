class StopNewResponsesOnOldRequestsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    InfoRequest.stop_new_responses_on_old_requests
  end
end
