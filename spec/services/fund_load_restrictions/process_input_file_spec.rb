require "rails_helper"

RSpec.describe FundLoadRestrictions::ProcessInputFile, type: :service do
  let(:input_path) { Rails.root.join('spec', 'fixtures', 'input.json') }
  let(:rules_path) { Rails.root.join('spec', 'fixtures', 'rules.json') }
  let(:input_file) { File.read(input_path) }
  let(:rules_file) { File.read(rules_path) }

  before :each do
    Rails.logger.info "Loading rules in test case -------------------------------------------------------------"
    rules = JSON.parse(rules_file, symbolize_names: true)
    rules.each do |attrs|
      rule = FundLoadRestrictions::VelocityLimitRule.find_or_initialize_by(name: attrs[:name])
      rule.config = attrs[:config]
      rule.active = attrs[:active]
      rule.save!
    end

    FundLoadRestrictions::VelocityRuleRegistry.load!
    FundLoadRestrictions::ACTIVE_VELOCITY_RULES.replace(FundLoadRestrictions::VelocityRuleRegistry.current)
  end

  it "persists upload, computes chunks, and enqueues chunk jobs" do
    expect { described_class.new(File.open(input_path), chunk_size: 100).call }.to change(FundLoadRestrictions::Submission, :count).by(2003)
  end
end


