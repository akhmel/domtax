module FundLoadRestrictions
  class Submission < ApplicationRecord
    self.table_name = "fund_load_restrictions_submissions"

    belongs_to :customer, class_name: "FundLoadRestrictions::Customer"
    has_many :submission_velocity_limit_results,
      class_name: "FundLoadRestrictions::SubmissionVelocityLimitResult",
      foreign_key: :submission_id,
      dependent: :destroy
    has_many :submission_sanction_results,
      class_name: "FundLoadRestrictions::SubmissionSanctionResult",
      foreign_key: :submission_id,
      dependent: :destroy

    scope :accepted, -> { where(accepted: true) }
    scope :for_day, ->(time) { where(load_datetime: time.beginning_of_day..time.end_of_day) }
    scope :for_week, ->(time) { where(load_datetime: time.beginning_of_week..time.end_of_week) }
    scope :sum_by_day, ->(time) { where(load_datetime: time.beginning_of_day..time.end_of_day).sum(:load_amount_cents) }
    scope :sum_by_week, ->(time) { where(load_datetime: time.beginning_of_week..time.end_of_week).sum(:load_amount_cents) }
    scope :count_by_day, ->(time) { where(load_datetime: time.beginning_of_day..time.end_of_day).count }
    scope :count_by_week, ->(time) { where(load_datetime: time.beginning_of_week..time.end_of_week).count }

    validates :customer_id, presence: true
    validates :load_amount_cents, presence: true, numericality: { only_integer: true }
    validates :currency, presence: true, allow_nil: true
    validates :load_datetime, presence: true
   
    def self.ransackable_associations(_auth_object = nil)
      %w[customer submission_velocity_limit_results submission_sanction_results]
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w[id customer_id load_amount_cents currency load_datetime created_at updated_at]
    end

    #get submission with submission velocity limit results,
    #extract id, ext_customer_id, accepted, decline_reason 
    #use class method
    def self.submission_with_velocity_limit_results
      joins(:submission_velocity_limit_results, :customer)
        .select(
          [
            "#{table_name}.uuid AS id",
            "#{FundLoadRestrictions::Customer.table_name}.ext_customer_id",
            "#{FundLoadRestrictions::SubmissionVelocityLimitResult.table_name}.accepted",
            "#{FundLoadRestrictions::SubmissionVelocityLimitResult.table_name}.decline_reason"
          ].join(", ")
        )
    end
  end
end


