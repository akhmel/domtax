class CreateFundLoadRestrictionsVelocityLimitRules < ActiveRecord::Migration[8.1]
  
  def up
    create_table 'fund_load_restrictions_velocity_limit_rules', id: false, force: :cascade do |t|
      t.uuid :uuid, primary_key: true, default: "gen_random_uuid()"
      t.string :name, null: false
      t.jsonb :config, null: false, default: {}
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :fund_load_restrictions_velocity_limit_rules, :name, unique: true, name: "idx_flr_velocity_limit_rules_name"
    add_index :fund_load_restrictions_velocity_limit_rules, :active, name: "idx_flr_velocity_limit_rules_active"
  end

  def down
    drop_index :fund_load_restrictions_velocity_limit_rules, :name, unique: true, name: "idx_flr_velocity_limit_rules_name"
    drop_index :fund_load_restrictions_velocity_limit_rules, :active, name: "idx_flr_velocity_limit_rules_active"
    drop_table 'fund_load_restrictions_velocity_limit_rules'
  end
end


