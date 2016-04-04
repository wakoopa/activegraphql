module ActiveGraphql
  module Support
    class Fancy
      def initialize(attrs = {})
        attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
      end
    end
  end
end
