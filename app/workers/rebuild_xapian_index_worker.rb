class RebuildXapianIndexWorker
  include Sidekiq::Worker

  def perform
    # Models to rebuild and true for verbose
    ActsAsXapian.rebuild_index([PublicBody, User, InfoRequestEvent], true)
  end
end
