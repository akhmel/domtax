class CreateFundLoadRestrictionsSanctions < ActiveRecord::Migration[8.1]
  def up
    create_table 'fund_load_restrictions_sanctions', id: false, force: :cascade do |t|
      t.uuid :uuid, primary_key: true, default: "gen_random_uuid()"
      t.string :name, null: false
      t.integer :sanction_type, null: false, default: 0
      t.jsonb :config, null: false, default: {}
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :fund_load_restrictions_sanctions, :sanction_type, name: "idx_flr_sanctions_type"
    add_index :fund_load_restrictions_sanctions, :name, unique: true, name: "idx_flr_sanctions_name"
    add_index :fund_load_restrictions_sanctions, :active, name: "idx_flr_sanctions_active"
  end

  def down
    drop_index :fund_load_restrictions_sanctions, :sanction_type, name: "idx_flr_sanctions_type"
    drop_index :fund_load_restrictions_sanctions, :name, unique: true, name: "idx_flr_sanctions_name"
    drop_index :fund_load_restrictions_sanctions, :active, name: "idx_flr_sanctions_active"

    drop_table :fund_load_restrictions_sanctions
  end
end
