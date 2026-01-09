module FundLoadRestrictions
  class SubmissionSanctionResult < ApplicationRecord
    self.table_name = "fund_load_restrictions_submission_sanction_results"

    belongs_to :submission, class_name: "FundLoadRestrictions::Submission"
    belongs_to :sanction, class_name: "FundLoadRestrictions::Sanction"

    validates :submission_id, presence: true
    validates :sanction_id, presence: true

    def self.ransackable_associations(_auth_object = nil)
      %w[submission sanction]
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w[uuid id submission_id sanction_id created_at updated_at]
    end
  end
end
