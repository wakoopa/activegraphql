require 'activegraphql/support/fancy'

module ActiveGraphQL
  class Fetcher < Support::Fancy
    attr_accessor :url, :klass, :action, :params, :query

    class Error < StandardError; end

    def initialize(attrs)
      super(attrs)
    end

    def query
      @query ||= Query.new(url: url, action: action, params: params)
    end

    def in_locale(locale)
      query.locale = locale if locale.present?
      self
    end

    def fetch(*graph)
      response = query.get(*graph)
      return if response.blank?

      case response
      when Hash
        klass.new(response)
      when Array
        response.map { |h| klass.new(h) }
      else
        raise Error, "Unexpected response for query: #{response}"
      end
    end
  end
end
