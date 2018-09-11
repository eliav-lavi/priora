module Priora
  class Configuration
    def initialize
      @conversion_lambdas = {
          TrueClass: -> (_) { 1 },
          FalseClass: -> (_) { 0 },
          NilClass: -> (_) { 0 }
      }
    end

    def conversion_lambda_for(klass)
      @conversion_lambdas[klass.to_s.to_sym]
    end

    def add_conversion_lambda(klass, lambda)
      raise InvalidConversionLambda if lambda.arity > 1
      @conversion_lambdas[klass.to_s.to_sym] = lambda
    end

    def remove_conversion_lambda(klass)
      @conversion_lambdas.delete_if { |k, _| k == klass.to_s.to_sym }
    end
  end
end
