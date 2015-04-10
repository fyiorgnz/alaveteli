class UpdateXapianIndexWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(5) }

  def perform
    ActsAsXapian.update_index(false, true)
  end
end
