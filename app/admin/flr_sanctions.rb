ActiveAdmin.register FundLoadRestrictions::Sanction, as: "Sanctions" do
  permit_params :customer_id, :reason, :active

  index do
    selectable_column
    id_column
    column :customer
    column :reason
    column :active
    column :created_at
    actions
  end
end


