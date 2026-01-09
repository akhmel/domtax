module FundLoadRestrictions


  #Define Model for Velocity Limit Rules
  #Velocity Limit Rules are used to limit the number of submissions a customer can make in a given time period
  #The rule is defined by a name, a velocity limit type, a config, and an active flag

  class VelocityLimitRule < ApplicationRecord
    self.table_name = "fund_load_restrictions_velocity_limit_rules"

    has_many :submission_velocity_limit_results, class_name: "FundLoadRestrictions::SubmissionVelocityLimitResult", dependent: :destroy

    def self.ransackable_attributes(_auth_object = nil)
      %w[id name velocity_limit_type config active created_at updated_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[submission_velocity_limit_results]
    end
  end
end


