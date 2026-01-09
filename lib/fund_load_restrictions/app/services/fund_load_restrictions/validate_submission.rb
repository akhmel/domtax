module FundLoadRestrictions
  class ValidateSubmission
    include FundLoadRestrictions::DollarToCents
    # @param payload [Hash] payload from input file
    # The format of the payload is expected to be:
    # { "customer_id" => "12345", "load_amount" => "$10.00", "time" => "2026-01-01T00:00:00Z" }
    # @return [void]
    def initialize(payload)
      @payload = payload
      @load_amount_cents = parse_amount_to_cents(payload["load_amount"])
      @load_datetime = Time.parse(payload["time"].to_s)
    end

    def call
      customer = Customer.find_or_create_by!(ext_customer_id: @payload["customer_id"].to_s)

      # Evaluate against dynamically loaded velocity rules
      Rails.logger.info "Evaluating submission for customer #{customer.id} with payload #{@payload.inspect}"
      rules = FundLoadRestrictions::VelocityRuleRegistry.current

      rules.each do |rule|
        Rails.logger.info "Evaluating rule: #{rule.name}"
        accepted, reason = rule.instance.evaluate(customer_payload: @payload)
        ActiveRecord::Base.transaction do
          submission = Submission.create!(
            customer_id: customer.id,
            load_amount_cents: @load_amount_cents,
            load_datetime: @load_datetime,
            accepted: true,
          )
          SubmissionVelocityLimitResult.create!(
            submission_id: submission.id,
            rule_id: rule.id,
            accepted: accepted,
            decline_reason: reason
          )
        end
        break unless accepted
      end
    end

    private

  end
end


