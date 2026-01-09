ActiveAdmin.register FundLoadRestrictions::VelocityLimitRule, as: "Rules" do
  permit_params :name, :rule_type, :enabled, :config

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :active
      f.input :config, as: :text, input_html: { rows: 6 }, hint: "Provide JSON, e.g. {\"limit_cents\":500000}"
    end
    f.actions
  end

  controller do
    def create
      params[:fund_load_restrictions_rule][:config] = parse_json(params[:fund_load_restrictions_rule][:config])
      super
    end

    def update
      params[:fund_load_restrictions_rule][:config] = parse_json(params[:fund_load_restrictions_rule][:config])
      super
    end

    private

    def parse_json(value)
      return {} if value.blank?
      return value if value.is_a?(Hash)
      JSON.parse(value)
    rescue JSON::ParserError
      {}
    end
  end
end


