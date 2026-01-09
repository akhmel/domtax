class CreateFundLoadRestrictionsCustomers < ActiveRecord::Migration[8.1]
  def up
    create_table 'fund_load_restrictions_customers', id: false, force: :cascade do |t|
      t.uuid :uuid, primary_key: true, default: "gen_random_uuid()"
      t.bigint :ext_customer_id, null: false
      t.timestamps
    end
    add_index :fund_load_restrictions_customers, :ext_customer_id, unique: true, name: "idx_flr_customers_ext_customer_id"
  end

  def down
    drop_index :fund_load_restrictions_customers, :ext_customer_id, unique: true, name: "idx_flr_customers_ext_customer_id"
    drop_table 'fund_load_restrictions_customers'
  end
end


