require "rails_helper"

RSpec.describe FundLoadRestrictions::VelocityRules::DailyFundLoadLimit do
  let(:payload) { { "customer_id" => "101", "load_amount" => "$30.00", "time" => "2026-01-01T12:00:00Z" } }

  def stub_sum_today(spent_today)
    customer = instance_double("FundLoadRestrictions::Customer")
    submissions = instance_double("Relation")
    accepted_rel = instance_double("AcceptedRelation")
    allow(customer).to receive(:submissions).and_return(submissions)
    allow(submissions).to receive(:accepted).and_return(accepted_rel)
    allow(accepted_rel).to receive(:sum_by_day).with(instance_of(Time)).and_return(spent_today)
    allow(FundLoadRestrictions::Customer).to receive(:find_by).with(ext_customer_id: payload["customer_id"]).and_return(customer)
  end

  it "accepts when today's spent + load is <= limit" do
    rule = described_class.new(config: { "daily_fund_load_limit" => 10_000 })
    stub_sum_today(7_000)
    result = rule.evaluate(customer_payload: payload)
    accepted, reason = result.is_a?(Array) ? result : [result, nil]
    expect(accepted).to be(true)
    expect([nil, "PASSED"]).to include(reason)
  end

  it "declines when today's spent + load exceeds limit" do
    rule = described_class.new(config: { "daily_fund_load_limit" => 10_000 })
    stub_sum_today(9_999)
    # load_amount is $30.00 => 3000 cents, 9999 + 3000 > 10000 => decline
    result = rule.evaluate(customer_payload: payload)
    accepted, reason = result.is_a?(Array) ? result : [result, nil]
    expect(accepted).to be(false)
    expect(reason).to eq("daily amount limit exceeded, available amount for today is 1 cents")
  end

  it "accepts when today's spent + load equals the limit" do
    rule = described_class.new(config: { "daily_fund_load_limit" => 10_000 })
    stub_sum_today(7_000)
    result = rule.evaluate(customer_payload: payload)
    accepted, reason = result.is_a?(Array) ? result : [result, nil]
    expect(accepted).to be(true)
    expect([nil, "PASSED"]).to include(reason)
  end

  it "accepts when limit is zero or missing" do
    stub_sum_today(100)
    result = described_class.new(config: {}).evaluate(customer_payload: payload)
    accepted, reason = result.is_a?(Array) ? result : [result, nil]
    expect(accepted).to be(true)
    expect([nil, "PASSED"]).to include(reason)
  end
end


