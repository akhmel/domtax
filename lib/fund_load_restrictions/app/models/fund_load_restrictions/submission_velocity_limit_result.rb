module FundLoadRestrictions
  class SubmissionVelocityLimitResult < ApplicationRecord
    self.table_name = "fund_load_restrictions_submission_velocity_limit_results"

    belongs_to :submission, class_name: "FundLoadRestrictions::Submission"
    belongs_to :velocity_limit_rule, class_name: "FundLoadRestrictions::VelocityLimitRule", foreign_key: "rule_id"

    validates :rule_id, presence: true
    validates :submission_id, presence: true

    def self.ransackable_associations(_auth_object = nil)
      %w[submission velocity_limit_rule]
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w[uuid id submission_id rule_id accepted decline_reason created_at updated_at]
    end
  end
end
