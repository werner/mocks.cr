module Mocks
  class HaveReceivedExpectation
    def initialize(@receive)
    end

    def match(@target)
      method.received?(oid, @receive.args)
    end

    def failure_message
      "expected: #{expected}\n     got: #{got}"
    end

    def negative_failure_message
      "expected: receive != #{expected}\n     got: #{got}"
    end

    private def method
      Registry
        .for(target_class_name(@target))
        .fetch_method(@receive.method_name)
    end

    private def self_method?
      @receive.method_name.starts_with?("self.")
    end

    private def target_class_name(target)
      return target.name if self_method? && target.is_a?(Class)
      target.class.name
    end

    private def oid
      Registry::ObjectId.build(@target)
    end

    private def got
      if args = last_args
        return "#{@receive.method_name}#{args.inspect}"
      end

      "nil"
    end

    def expected
      "#{@receive.method_name}#{@receive.args.inspect}"
    end

    private def last_args
      method.last_received_args(oid)
    end
  end
end
