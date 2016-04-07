require 'activegraphql/support/fancy'

module ActiveGraphql
  class Fetcher < Support::Fancy
    attr_accessor :url, :klass, :action, :params, :query

    class Error < StandardError; end

    def initialize(attrs)
      super(attrs)
      self.query = Query.new(url: url, action: action, params: params)
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
        fail Error, "Unexpected response for query: #{response}"
      end
    end
  end
end
