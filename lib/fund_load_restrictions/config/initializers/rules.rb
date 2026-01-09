# Initialize in-memory registry of active velocity limit rules from DB.
#
# Safe to run during boot and in console; guarded to avoid errors before migrations.
#
# Access:
#   FundLoadRestrictions::ACTIVE_VELOCITY_RULES # => Array of OpenStructs with name, config, active
#   FundLoadRestrictions::VelocityRuleRegistry.current # => same as above
#
require "ostruct"

module FundLoadRestrictions
  module VelocityRuleRegistry
    mattr_accessor :current

    def self.load!
      Rails.logger.info "Loading velocity rule registry in initializer"
      return self.current = [] unless defined?(ActiveRecord::Base)
      return self.current = [] unless ActiveRecord::Base.connection.schema_cache.data_source_exists?("fund_load_restrictions_velocity_limit_rules")

      rules = FundLoadRestrictions::VelocityLimitRule.where(active: true).order(:name).map do |rule|
        cfg = rule.config.is_a?(Hash) ? rule.config : {}
        key = cfg.keys.first.to_s
        klass_name = key.camelize
        fqcn = "FundLoadRestrictions::VelocityRules::#{klass_name}"
        klass = fqcn.safe_constantize
        unless klass
          warn "[FundLoadRestrictions] Unknown velocity rule class for key=#{key.inspect} (expected #{fqcn})"
          next nil
        end
        begin
          instance = klass.new(config: cfg)
          ::OpenStruct.new(id: rule.id, name: rule.name, key: key, klass: klass, instance: instance)
        rescue StandardError => e
          warn "[FundLoadRestrictions] Failed to instantiate #{fqcn}: #{e.class}: #{e.message}"
          nil
        end
      end.compact

      self.current = rules
    rescue StandardError => e
      # Do not block boot due to registry load errors; log and continue with empty registry.
      warn "[FundLoadRestrictions] VelocityRuleRegistry.load! failed: #{e.class}: #{e.message}"
      self.current = []
    end
  end

  # Back-compat constant for easy access
  remove_const(:ACTIVE_VELOCITY_RULES) if const_defined?(:ACTIVE_VELOCITY_RULES)
  ACTIVE_VELOCITY_RULES = []
end

# Reload registry on each reloader pass (development) and after code changes.
if defined?(Rails)
  Rails.application.config.to_prepare do
    FundLoadRestrictions::VelocityRuleRegistry.load!
    FundLoadRestrictions::ACTIVE_VELOCITY_RULES.replace(FundLoadRestrictions::VelocityRuleRegistry.current)
  end
end

