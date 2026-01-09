ActiveAdmin.register FundLoadRestrictions::Customer, as: "FLR Customer" do
  permit_params :ext_customer_id

  # Filters
  filter :ext_customer_id
  remove_filter :name

  index do
    selectable_column

    column :ext_customer_id
    column :created_at
    actions
  end
end


