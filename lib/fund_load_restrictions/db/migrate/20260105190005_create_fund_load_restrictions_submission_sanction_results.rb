# This migration comes from fund_load_restrictions (originally 20260105190005)
class CreateFundLoadRestrictionsSubmissionSanctionResults < ActiveRecord::Migration[8.1]
  def up
    create_table 'fund_load_restrictions_submission_sanction_results', id: false, force: :cascade do |t|
      t.uuid :uuid, primary_key: true, default: "gen_random_uuid()"
      t.references :submission, type: :uuid, null: false, foreign_key: { to_table: :fund_load_restrictions_submissions, primary_key: :uuid }, index: { name: "idx_flr_submission_sanction_results_submission_id" }
      t.references :sanction, type: :uuid, null: false, foreign_key: { to_table: :fund_load_restrictions_sanctions, primary_key: :uuid }, index: { name: "idx_flr_submission_sanction_results_sanction_id" }
      t.timestamps
    end
    add_index :fund_load_restrictions_submission_sanction_results, [:submission_id, :sanction_id], unique: true, name: "idx_flr_submission_sanction_results_unique"
  end

  def down
    drop_index :fund_load_restrictions_submission_sanction_results, [:submission_id, :sanction_id], unique: true, name: "idx_flr_submission_sanction_results_unique"
    drop_table 'fund_load_restrictions_submission_sanction_results'
  end
end


