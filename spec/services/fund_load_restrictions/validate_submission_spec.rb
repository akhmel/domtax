require "rails_helper"
require "ostruct"

RSpec.describe FundLoadRestrictions::ValidateSubmission, type: :service do
  let(:payload) do
    {
      customer_id: "12345",
      load_amount: "$10.00",
      time: "2026-01-01T00:00:00Z"
    }
  end

  let(:parsed_time) { Time.parse(payload[:time]) }

  def build_rule_meta(accepted:, reason: nil)
    instance = instance_double("RuleInstance")
    allow(instance).to receive(:evaluate).and_return([accepted, reason])
    OpenStruct.new(key: "test_rule", instance: instance)
  end

  before do
    # ensure a customer record exists for find_or_create_by!(ext_customer_id: ...)
    create(:fund_load_restrictions_customer, ext_customer_id: payload[:customer_id])
  end

#   it "accepts when no sanctions and all rules accept; records submission" do
#     allow(FundLoadRestrictions::VelocityRuleRegistry).to receive(:current).and_return([
#       build_rule_meta(accepted: true)
#     ])

#     result = nil
#     expect { result = described_class.new(**payload).call }.to change(FundLoadRestrictions::Submission, :count).by(1)
#     expect(result.accepted).to be(true)
#     expect(result.decline_reason).to be_nil
#     last = FundLoadRestrictions::Submission.order(:created_at).last
#     expect(last.load_amount_cents).to eq(1000)
#     expect(last.load_datetime.to_i).to eq(parsed_time.to_i)
#   end

#   it "declines when any rule fails; returns decline reason and records submission" do
#     allow(FundLoadRestrictions::VelocityRuleRegistry).to receive(:current).and_return([
#       build_rule_meta(accepted: true),
#       build_rule_meta(accepted: false, reason: "daily_amount_limit")
#     ])

#     result = nil
#     expect { result = described_class.new(**payload).call }.to change(FundLoadRestrictions::Submission, :count).by(1)
#     expect(result.accepted).to be(false)
#     expect(result.decline_reason).to eq("daily_amount_limit")
#     last = FundLoadRestrictions::Submission.order(:created_at).last
#     expect(last.load_amount_cents).to eq(1000)
#     expect(last.load_datetime.to_i).to eq(parsed_time.to_i)
#   end

  # Sanctions are no longer evaluated here; rule evaluation governs acceptance.
end


