require 'active_support/core_ext'
require 'hashie/mash'

module ActiveGraphQL
  class Model < ::Hashie::Mash
    class Error < StandardError; end

    class << self
      attr_accessor :config

      # This provides ability to configure the class inherited from here.
      #  Also field classes will have the configuration.
      #
      #  Example:
      #    class BaseModelToMyService < ActiveGraphql::Model
      #      configure url: 'http://localhost:3000/graphql'
      #    end
      #
      #    class ModelToMyService < BaseModelToMyService
      #    end
      #
      #    BaseModelToMyService.config
      #    => { url: "http://localhost:3000/graphql" }
      #
      #    ModelToMyService.url
      #    => { url: "http://localhost:3000/graphql" }
      def configure(config = {})
        configurable_class.config ||= {}
        configurable_class.config.merge!(config)
      end

      # Resolves the class who is extending from ActiveGraphql::Model.
      #
      #  This provides the capability for configuring inheritable classes with
      #  specific configuration to the corresponding graphql service.
      def configurable_class
        ancestors[ancestors.find_index(ActiveGraphQL::Model) - 1]
      end

      def all
        build_fetcher(name.demodulize.underscore.pluralize.to_sym)
      end

      def where(conditions = {})
        build_fetcher(name.demodulize.underscore.pluralize.to_sym, conditions)
      end

      def find_by(conditions = {})
        build_fetcher(name.demodulize.underscore.to_sym, conditions)
      end

      def build_fetcher(action, params = nil)
        Fetcher.new(config: configurable_class.config,
                    klass: self,
                    action: action,
                    params: params)
      end
    end
  end
end
