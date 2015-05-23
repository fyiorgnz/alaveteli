module XapianTestHelpers
  # Use the before create job hook to simulate a race condition with
  # another process by creating an acts_as_xapian_job record for the
  # same model:
  def with_duplicate_xapian_job_creation
      InfoRequestEvent.module_eval do
          def xapian_before_create_job_hook(action, model, model_id)
              ActsAsXapian::ActsAsXapianJob.create!(:model => model,
                                                    :model_id => model_id,
                                                    :action => action)
          end
      end
      yield
  ensure
      InfoRequestEvent.module_eval do
          def xapian_before_create_job_hook(action, model, model_id)
          end
      end
  end
end