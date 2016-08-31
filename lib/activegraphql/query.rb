require 'httparty'
require 'active_support/inflector'
require 'activegraphql/support/fancy'

module ActiveGraphQL
  class Query < Support::Fancy
    attr_accessor :config, :action, :params, :locale, :graph, :response

    class ServerError < StandardError; end

    def get(*graph)
      self.graph = graph

      self.response = HTTParty.get(config[:url], request_options)

      raise(ServerError, response_error_messages) if response_errors.present?
      response_data
    end

    def request_options
      {}.tap do |opts|
        opts[:query] = request_params
        opts[:headers] = request_headers if request_headers.present?
        opts.merge!(config[:http]) if config[:http].present?
      end
    end

    def request_headers
      {}.tap do |headers|
        headers['Authorization'] = "Bearer #{auth_token}" if auth_header?
        headers['Accept-Language'] = locale.to_s if locale.present?
      end
    end

    def request_params
      { query: to_s }
    end

    def response_data
      return unless response['data']
      to_snake_case(response['data'][qaction])
    end

    def response_errors
      to_snake_case(response['errors'])
    end

    def response_error_messages
      response_errors.map { |e| e[:message] }
    end

    def to_s
      str = "{ #{qaction}"
      str << (qparams.present? ? "(#{qparams}) {" : ' {')
      str << " #{qgraph(graph)} } }"
      str
    end

    def qaction
      action.to_s.camelize(:lower)
    end

    def qparams
      return if params.blank?

      param_strings = params.map do |k, v|
        "#{k.to_s.camelize(:lower)}: \"#{v}\""
      end

      param_strings.join(', ')
    end

    def qgraph(graph)
      graph_strings = graph.map do |item|
        case item
        when Symbol
          item.to_s.camelize(:lower)
        when Hash
          item.map { |k, v| "#{k.to_s.camelize(:lower)} { #{qgraph(v)} }" }
        end
      end

      graph_strings.join(', ')
    end

    private

    def auth_header?
      auth_strategy == :bearer
    end

    def auth_config
      @auth_config ||= config[:auth] || {}
    end

    def auth_strategy
      @auth_strategy ||= auth_config[:strategy]
    end

    # ActiveGraphQL currently supports bearer authorization with given class to encode.
    # So if the "bearer" is not configured or the "class" is not present it's
    # returning a nil token.
    def auth_token
      return if auth_config[:strategy] != :bearer || auth_config[:class].blank?
      @auth_token ||= auth_config[:class].encode
    end

    def to_snake_case(value)
      case value
      when Array
        value.map { |v| to_snake_case(v) }
      when Hash
        Hash[value.map { |k, v| [k.to_s.underscore.to_sym, to_snake_case(v)] }]
      else
        value
      end
    end
  end
end
