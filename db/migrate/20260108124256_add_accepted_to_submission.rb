class AddAcceptedToSubmission < ActiveRecord::Migration[8.1]
  def up
    add_column :fund_load_restrictions_submissions, :accepted, :boolean, default: false, null: false
  end

  def down
    remove_column :fund_load_restrictions_submissions, :accepted
  end
end
