# -*- encoding : utf-8 -*-
class EditInfoRequestBatchIndex < !rails5? ? ActiveRecord::Migration : ActiveRecord::Migration[4.2] # 4.0
  def change
    remove_index :info_request_batches, :column =>  [:user_id, :body, :title]
    add_index :info_request_batches, [:user_id, :title]
  end
end
