module Priora
  class Priority
    DIRECTION_DESC = :desc
    DIRECTION_ASC = :asc

    DIRECTIONAL_METHODS = {
        DIRECTION_DESC => :+,
        DIRECTION_ASC => :-
    }

    attr_reader :attribute, :direction

    def initialize(attribute:, direction: DIRECTION_DESC)
      @attribute = attribute
      @direction = direction
    end

    def comparable_value_from(object)
      raw_value = object.send(@attribute)
      numeric_value = numeric_value_from(raw_value)
      directional_value_from(numeric_value)
    end

    private

    def numeric_value_from(raw_value)
      conversion_lambda = Priora.configuration.conversion_lambda_for(raw_value.class)
      conversion_lambda ? conversion_lambda.call(raw_value) : raw_value
    end

    def directional_value_from(numeric_value)
      0.send(DIRECTIONAL_METHODS[@direction], numeric_value)
    end
  end
end
