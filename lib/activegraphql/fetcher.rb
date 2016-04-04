require 'activegraphql/support/fancy'

module ActiveGraphql
  class Fetcher < Support::Fancy
    attr_accessor :url, :klass, :action, :params, :query

    def initialize(attrs)
      super(attrs)
      self.query = Query.new(url: url, action: action, params: params)
    end

    def fetch(graph = {})
      response = query.get(graph)

      case response
      when Hash
        klass.new(query.response_data)
      when Array
        query.response_data.map { |h| klass.new(h) }
      else
        fail "Unexpected response for query: #{query.response_data} "
      end
    end
  end
end
