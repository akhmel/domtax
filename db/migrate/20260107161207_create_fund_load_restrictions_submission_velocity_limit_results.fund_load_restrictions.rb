# This migration comes from fund_load_restrictions (originally 20260105175142)
# This migration comes from fund_load_restrictions (originally 20260105175142)
class CreateFundLoadRestrictionsSubmissionVelocityLimitResults < ActiveRecord::Migration[8.1]

  def up
    create_table 'fund_load_restrictions_submission_velocity_limit_results', id: false, force: :cascade do |t|
      t.uuid :uuid, primary_key: true, default: "gen_random_uuid()"
      t.references :submission, type: :uuid, null: false, foreign_key: { to_table: :fund_load_restrictions_submissions, primary_key: :uuid }, index: { name: "idx_flr_vel_results_submission_id" }
      t.references :rule, type: :uuid, null: false, foreign_key: { to_table: :fund_load_restrictions_velocity_limit_rules, primary_key: :uuid }, index: { name: "idx_flr_vel_results_rule_id" }
      t.boolean :accepted, null: false, default: false
      t.string :decline_reason, null: true
      t.timestamps
    end
    add_index :fund_load_restrictions_submission_velocity_limit_results, [:submission_id, :rule_id], unique: true, name: "idx_flr_vel_results_unique"
  end

  def down
    drop_index :fund_load_restrictions_submission_velocity_limit_results, [:submission_id, :rule_id], unique: true, name: "idx_flr_vel_results_unique"
    drop_table 'fund_load_restrictions_submission_velocity_limit_results'
  end
end
