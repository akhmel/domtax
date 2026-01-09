# config/initializers/money.rb
Money.locale_backend = :i18n
Money.rounding_mode = BigDecimal::ROUND_HALF_UP
