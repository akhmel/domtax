FactoryBot.define do
  factory :fund_load_restrictions_customer, class: "FundLoadRestrictions::Customer" do
    ext_customer_id { SecureRandom.random_number(1_000_000).to_s }
  end
end


