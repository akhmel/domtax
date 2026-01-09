ActiveRecord::Base.transaction do

    # Idempotent seeds: ensure rules exist (by unique name) and update attributes without duplicating records
    rules = [
      { name: "Daily fund load limit",        config: { "daily_fund_load_limit" => 50000 },  active: true },
      { name: "Weekly fund load limit",       config: { "weekly_fund_load_limit" => 200000 }, active: true },
      { name: "Daily fund load count limit",  config: { "daily_fund_load_count_limit" => 3 }, active: true }
    ]

    rules.each do |attrs|
      rule = FundLoadRestrictions::VelocityLimitRule.find_or_initialize_by(name: attrs[:name])
      rule.config = attrs[:config]
      rule.active = attrs[:active]
      rule.save!
    end
end


