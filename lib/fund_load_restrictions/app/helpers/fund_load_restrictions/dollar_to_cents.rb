module FundLoadRestrictions
  module DollarToCents
    def parse_amount_to_cents(amount_str)
      money = Monetize.parse(amount_str.to_s, "USD") #Currency can be configured in the future for Production Environment
      money&.cents.to_i
    end
  end
end