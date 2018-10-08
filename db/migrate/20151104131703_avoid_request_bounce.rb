class AvoidRequestBounce < ActiveRecord::Migration
  def up
    change_column :info_requests, :handle_rejected_responses, :string, :null => false, :default => 'holding_pen'
    InfoRequest.update_all "handle_rejected_responses = 'holding_pen' where handle_rejected_responses = 'bounce'"

    # VIEW for Postfix
    execute <<-SQL
      CREATE VIEW info_requests_email AS
        SELECT format('fyi-request-%s-%s', id, idhash) AS allowed
        FROM info_requests WHERE allow_new_responses_from <> 'nobody'
    SQL
  end

  def down
    change_column :info_requests, :handle_rejected_responses, :string, :null => false, :default => 'bounce'
    execute <<-SQL
      DROP VIEW info_requests_email
    SQL
  end
end
