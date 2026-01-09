module FundLoadRestrictions
  module VelocityRules
    class WeeklyFundLoadLimit
      attr_reader :config
      include FundLoadRestrictions::DollarToCents

      #A customer can load a maximum of $20,000 per week
      def initialize(config:)
        @config = config || {}
      end

      def evaluate(customer_payload:)
        limit_cents = @config.fetch("weekly_fund_load_limit", 0).to_i
        return [true, "PASSED"] if limit_cents <= 0
        customer = Customer.find_by(ext_customer_id: customer_payload["customer_id"])
        spent_week = customer.submissions.accepted.sum_by_week(Time.parse(customer_payload["time"]))
        load_amount_cents = parse_amount_to_cents(customer_payload["load_amount"])
        Rails.logger.info "Spent week: #{spent_week}, WeeklyFundLoadLimit cents: #{limit_cents},"

        if spent_week >= limit_cents
          Rails.logger.info "WeeklyFundLoadLimit rule: Failed"
          return [false, "weekly amount limit exceeded, spent #{spent_week} cents, limit is #{limit_cents} cents"]
        end

        remaining = limit_cents - spent_week
        if (spent_week + load_amount_cents) > limit_cents
          Rails.logger.info "WeeklyFundLoadLimit rule: Failed, available amount for week is #{remaining}"
          return [false, "weekly amount limit exceeded, available amount for week is #{remaining} cents"]
        end

        Rails.logger.info "WeeklyFundLoadLimit rule: Passed"
        return [true, "PASSED"]
      end
    end
  end
end

