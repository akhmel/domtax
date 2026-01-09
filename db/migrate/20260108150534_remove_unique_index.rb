class RemoveUniqueIndex < ActiveRecord::Migration[8.1]
  def up
    #remove add_index :fund_load_restrictions_submissions, [:customer_id, :load_datetime], unique: true, name: "idx_flr_submissions_unique_per_customer"
    remove_index :fund_load_restrictions_submissions, [:customer_id, :load_datetime], unique: true, name: "idx_flr_submissions_unique_per_customer"
  end

  def down
    add_index :fund_load_restrictions_submissions, [:customer_id, :load_datetime], unique: true, name: "idx_flr_submissions_unique_per_customer"
  end
end
