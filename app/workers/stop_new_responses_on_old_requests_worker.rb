class StopNewResponsesOnOldRequestsWorker
  include Sidekiq::Worker

  def perform
    InfoRequest.stop_new_responses_on_old_requests
  end
end
