module FundLoadRestrictions
  module VelocityRules
    class DailyFundLoadCountLimit
      attr_reader :config

      def initialize(config:)
        @config = config || {}
      end

      def evaluate(customer_payload:)
        # #Fetch specific config for the rule
        limit_count = @config.fetch("daily_fund_load_count_limit", 0).to_i
        customer = Customer.find_by(ext_customer_id: customer_payload["customer_id"])
        customer_submissions = customer.submissions.accepted.for_day(Time.parse(customer_payload["time"]))
        count_today = customer_submissions.count
        Rails.logger.info "Count today: #{count_today}, Limit count: #{limit_count}"
        if (count_today + 1) > limit_count
          Rails.logger.info "DailyFundLoadCountLimit rule: Failed"
          return [false, "daily load count limit exceeded, count is #{count_today}, limit is #{limit_count}"]
        else
          Rails.logger.info "DailyFundLoadCountLimit rule: Passed"
          return [true, "PASSED"]
        end
      end
    end
  end
end
