ActiveAdmin.register FundLoadRestrictions::Submission, as: "FLR Submission" do
  actions :index, :show

  # Use concrete columns that exist on the model/table
  filter :customer_id
  filter :load_datetime
  filter :load_amount_cents
  filter :currency

  index do
    selectable_column
    column :customer_id
    column :load_amount_cents
    column :currency
    column :load_datetime
    column("Velocity Results") { |s| s.submission_velocity_limit_results.count }
    column("Sanction Results") { |s| s.submission_sanction_results.count }
    actions
  end

  show do
    attributes_table do
      row :id
      row :customer_id
      row :load_amount_cents
      row :currency
      row :load_datetime
      row :created_at
      row :updated_at
    end

    panel "Velocity Limit Results" do
      table_for resource.submission_velocity_limit_results do
        column :rule_id
        column :accepted
        column :decline_reason
        column :created_at
      end
    end

    panel "Sanction Results" do
      table_for resource.submission_sanction_results do
        column :sanction_id
        column :created_at
      end
    end
  end
end


