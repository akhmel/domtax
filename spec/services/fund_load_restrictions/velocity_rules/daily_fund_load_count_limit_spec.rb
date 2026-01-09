require "rails_helper"

RSpec.describe FundLoadRestrictions::VelocityRules::DailyFundLoadCountLimit do
  let(:payload) { { "customer_id" => "101", "load_amount" => "$1.00", "time" => "2026-01-01T12:00:00Z" } }

  def stub_count_today(count_today)
    customer = instance_double("FundLoadRestrictions::Customer")
    submissions = instance_double("Relation")
    accepted_rel = instance_double("AcceptedRelation")
    day_rel = instance_double("DayRelation")
    allow(customer).to receive(:submissions).and_return(submissions)
    allow(submissions).to receive(:accepted).and_return(accepted_rel)
    allow(accepted_rel).to receive(:for_day).with(instance_of(Time)).and_return(day_rel)
    allow(day_rel).to receive(:count).and_return(count_today)
    allow(FundLoadRestrictions::Customer).to receive(:find_by).with(ext_customer_id: payload["customer_id"]).and_return(customer)
  end

  it "accepts when today's count + 1 is <= limit" do
    rule = described_class.new(config: { "daily_fund_load_count_limit" => 3 })
    stub_count_today(2)
    result = rule.evaluate(customer_payload: payload)
    accepted = result.is_a?(Array) ? result.first : result
    expect(accepted).to be(true)
  end

  it "declines when today's count + 1 exceeds limit" do
    rule = described_class.new(config: { "daily_fund_load_count_limit" => 3 })
    stub_count_today(3)
    result = rule.evaluate(customer_payload: payload)
    accepted = result.is_a?(Array) ? result.first : result
    expect(accepted).to be(false)
  end

  it "accepts when today's count + 1 equals the limit" do
    rule = described_class.new(config: { "daily_fund_load_count_limit" => 3 })
    stub_count_today(2)
    result = rule.evaluate(customer_payload: payload)
    accepted = result.is_a?(Array) ? result.first : result
    expect(accepted).to be(true)
  end

  it "declines when limit is zero or missing" do
    stub_count_today(10)
    result = described_class.new(config: {}).evaluate(customer_payload: payload)
    accepted = result.is_a?(Array) ? result.first : result
    expect(accepted).to be(false)
  end
end


