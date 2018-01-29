# frozen_string_literal: true

module ERBLint
  class RunnerConfig
    class Error < StandardError; end

    def initialize(config = nil)
      @config = (config || {}).dup.deep_stringify_keys
    end

    def to_hash
      @config.dup
    end

    def for_linter(klass)
      klass_name = if klass.is_a?(String)
        klass.to_s
      elsif klass.is_a?(Class) && klass <= ERBLint::Linter
        klass.simple_name
      else
        raise ArgumentError, 'expected String or linter class'
      end
      linter_klass = LinterRegistry.find_by_name(klass_name)
      raise Error, "#{klass_name}: linter not found (is it loaded?)" unless linter_klass
      linter_klass.config_schema.new(config_hash_for_linter(klass_name))
    end

    def global_exclude
      @config['exclude'] || []
    end

    def merge(other_config)
      self.class.new(@config.deep_merge(other_config.to_hash))
    end

    def merge!(other_config)
      @config.deep_merge!(other_config.to_hash)
      self
    end

    class << self
      def default
        new(
          linters: {
            FinalNewline: { enabled: true },
            ParserErrors: { enabled: true },
            RightTrim: { enabled: true },
            SpaceAroundErbTag: { enabled: true },
            NoJavascriptTagHelper: { enabled: true },
            AllowedScriptType: { enabled: true },
            SpaceIndentation: { enabled: true },
          },
        )
      end
    end

    private

    def linters_config
      @config['linters'] || {}
    end

    def config_hash_for_linter(klass_name)
      config_hash = linters_config[klass_name] || {}
      config_hash['exclude'] ||= []
      config_hash['exclude'].concat(global_exclude) if config_hash['exclude'].is_a?(Array)
      config_hash
    end
  end
end
