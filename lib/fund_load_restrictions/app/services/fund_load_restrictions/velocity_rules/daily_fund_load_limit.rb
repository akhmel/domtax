module FundLoadRestrictions
  module VelocityRules
    class DailyFundLoadLimit
      attr_reader :config
      include FundLoadRestrictions::DollarToCents

      #A customer can load a maximum of $5,000 per day.
      def initialize(config:)
        @config = config || {}
      end

      def evaluate(customer_payload:)
        limit_cents = @config.fetch("daily_fund_load_limit", 0).to_i
        return [true, "PASSED"] if limit_cents <= 0
        customer = Customer.find_by(ext_customer_id: customer_payload["customer_id"])
        spent_today = customer.submissions.accepted.sum_by_day(Time.parse(customer_payload["time"]))
        load_amount_cents = parse_amount_to_cents(customer_payload["load_amount"])
        Rails.logger.info "Spent today: #{spent_today}, Limit cents: #{limit_cents}"

        if spent_today >= limit_cents
          Rails.logger.info "DailyFundLoadLimit rule: Failed"
          return [false, "daily amount limit exceeded, spent #{spent_today} cents, limit is #{limit_cents} cents"]
        end

        remaining = limit_cents - spent_today
        if (spent_today + load_amount_cents) > limit_cents
          Rails.logger.info "DailyFundLoadLimit rule: Failed, available amount for today is #{remaining}"
          return [false, "daily amount limit exceeded, available amount for today is #{remaining} cents"]
        end

        Rails.logger.info "DailyFundLoadLimit rule: Passed"
        return [true, "PASSED"]
      end
    end
  end
end

