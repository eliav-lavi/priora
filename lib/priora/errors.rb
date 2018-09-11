module Priora
  class UnsuppliedPrioritiesError < StandardError
    def initialize
      super('prioritization attributes must be declared in class or supplied manually!')
    end
  end

  class InvalidPrioritySyntaxError < StandardError
    def initialize(msg = 'priorities must be a symbol or an array/hash for directional priorities!')
      super
    end
  end

  class InvalidConversionLambda < StandardError
    def initialize
      super('conversion lambdas may take only 0 or 1 arguments!')
    end
  end
end
