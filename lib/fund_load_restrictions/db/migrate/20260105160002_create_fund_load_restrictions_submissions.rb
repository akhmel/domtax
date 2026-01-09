# This migration comes from fund_load_restrictions (originally 20260105160002)
class CreateFundLoadRestrictionsSubmissions < ActiveRecord::Migration[8.1]
  def up
    create_table 'fund_load_restrictions_submissions', id: false, force: :cascade do |t|
      t.uuid :uuid, primary_key: true, default: "gen_random_uuid()"
      t.references :customer, type: :uuid, null: false, foreign_key: { to_table: :fund_load_restrictions_customers, primary_key: :uuid }, index: { name: "idx_flr_submissions_customer_uuid" }
      t.integer :load_amount_cents, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.datetime :load_datetime, null: false
      t.timestamps
    end
    add_index :fund_load_restrictions_submissions, [:customer_id, :load_datetime], unique: true, name: "idx_flr_submissions_unique_per_customer"
  end

  def down
    drop_index :fund_load_restrictions_submissions, [:customer_id, :load_datetime], unique: true, name: "idx_flr_submissions_unique_per_customer"
    drop_table 'fund_load_restrictions_submissions'
  end
end


