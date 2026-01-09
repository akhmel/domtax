require "logger"

RSpec.configure do |config|
  config.before(:suite) do
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = Logger::Formatter.new
    logger.level = Logger::DEBUG

    Rails.logger = logger
    ActiveRecord::Base.logger = logger if defined?(ActiveRecord::Base)
    ActiveSupport::Dependencies.logger = logger if ActiveSupport::Dependencies.respond_to?(:logger=)
  end
end


