module FundLoadRestrictions
  class Sanction < ApplicationRecord
    self.table_name = "fund_load_restrictions_sanctions"

    has_many :submission_sanction_results, class_name: "FundLoadRestrictions::SubmissionSanctionResult", dependent: :destroy

    validates :sanction_type, presence: true
    validates :config, presence: true
    validates :enabled, presence: true

    def self.ransackable_associations(_auth_object = nil)
      %w[submission_sanction_results]
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w[id name sanction_type config enabled active reason customer_id created_at updated_at]
    end
  end
end


