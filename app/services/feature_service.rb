module FeatureService
  class << self
    def require(feature_name)
      unless enabled?(feature_name)
        raise "Feature #{feature_name} is disabled"
      end

      true
    end

    def enabled?(feature_name)
      segments = feature_name.to_s.split(".")

      segments.reduce(Settings.features) { |config, segment| config[segment] }
    end
  end
end
