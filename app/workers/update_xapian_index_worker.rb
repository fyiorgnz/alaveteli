class UpdateXapianIndexWorker
  include Sidekiq::Worker

  def perform
    ActsAsXapian.update_index(false, true)
  end
end
