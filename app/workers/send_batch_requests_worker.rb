class SendBatchRequestsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(10) }

  def perform
    InfoRequestBatch.send_batches
  end
end
