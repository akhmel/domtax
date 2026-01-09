module FundLoadRestrictions
  class Customer < ApplicationRecord
    self.table_name = "fund_load_restrictions_customers"

    has_many :submissions, class_name: "FundLoadRestrictions::Submission", dependent: :destroy
    has_many :submission_results,
      through: :submissions,
      source: :submission_velocity_limit_results
    has_many :submission_sanction_results,
      through: :submissions,
      source: :submission_sanction_results

    validates :ext_customer_id, presence: true, uniqueness: true

    #add ransack
    def self.ransackable_associations(_auth_object = nil)
      %w[submission_results submission_sanction_results submissions]
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w[id ext_customer_id created_at updated_at]
    end

    def submissions_with_velocity_limit_results
      submissions.joins(:submission_velocity_limit_results)
      .select("submissions.id, submissions.ext_customer_id, submission_velocity_limit_results.accepted, submission_velocity_limit_results.decline_reason")
    end
  end
end


