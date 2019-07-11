class SendBatchRequestsWorker
  include Sidekiq::Worker

  def perform
    InfoRequestBatch.send_batches
  end
end
