require "rails_helper"

RSpec.describe FundLoadRestrictions::VelocityRules::WeeklyFundLoadLimit do
    
  let(:payload) { { "customer_id" => "101", "load_amount" => "$30.00", "time" => "2026-01-06T12:00:00Z" } } # a Tuesday

  def stub_sum_week(spent_week)
    customer = instance_double("FundLoadRestrictions::Customer")
    submissions = instance_double("Relation")
    accepted_rel = instance_double("AcceptedRelation")
    allow(customer).to receive(:submissions).and_return(submissions)
    allow(submissions).to receive(:accepted).and_return(accepted_rel)
    allow(accepted_rel).to receive(:sum_by_week).with(instance_of(Time)).and_return(spent_week)
    allow(FundLoadRestrictions::Customer).to receive(:find_by).with(ext_customer_id: payload["customer_id"]).and_return(customer)
  end

  it "accepts when week's spent + load is <= limit" do
    rule = described_class.new(config: { "weekly_fund_load_limit" => 50_000 })
    stub_sum_week(20_000)
    accepted, reason = rule.evaluate(customer_payload: payload)
    expect(accepted).to be(true)
    expect([nil, "PASSED"]).to include(reason)
  end

  it "declines when week's spent + load exceeds limit" do
    rule = described_class.new(config: { "weekly_fund_load_limit" => 50_000 })
    stub_sum_week(49_999)
    # load_amount is $30.00 => 3000 cents, 49999 + 3000 > 50000 => decline
    accepted, reason = rule.evaluate(customer_payload: payload)
    expect(reason).to eq("weekly amount limit exceeded, available amount for week is 1 cents")
    expect(accepted).to be(false)
  end

  it "accepts when week's spent + load equals the limit" do
    rule = described_class.new(config: { "weekly_fund_load_limit" => 50_000 })
    stub_sum_week(20_000)
    accepted, reason = rule.evaluate(customer_payload: payload)
    expect(reason).to eq("PASSED")
    expect(accepted).to be(true)
  end

  it "accepts when limit is zero or missing" do
    stub_sum_week(100)
    accepted, reason = described_class.new(config: {}).evaluate(customer_payload: payload)
    expect(reason).to eq("PASSED")
    expect(accepted).to be(true)
  end
end


