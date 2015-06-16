class UpdatePublicBodyStatsWorker
  include Sidekiq::Worker

  def perform
    PublicBody.find_each(:batch_size => 10) do |public_body|
      puts "Counting overdue requests for #{public_body.name}" if ENV['verbose']

      # Look for values of 'waiting_response_overdue' and
      # 'waiting_response_very_overdue' which aren't directly in the
      # described_state column, and instead need to be calculated:
      overdue_count = 0
      very_overdue_count = 0
      InfoRequest.find_each(:batch_size => 200,
                            :conditions => {
                                :public_body_id => public_body.id,
                                :awaiting_description => false,
                                :prominence => 'normal'
                            }) do |ir|
        case ir.calculate_status
        when 'waiting_response_very_overdue'
          very_overdue_count += 1
        when 'waiting_response_overdue'
          overdue_count += 1
        end
      end
      public_body.info_requests_overdue_count = overdue_count + very_overdue_count
      public_body.no_xapian_reindex = true
      public_body.without_revision do
          public_body.save!
      end
    end
  end
end
