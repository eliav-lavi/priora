module Priora
  module ClassMethods
    attr_reader :priorities

    def prioritize_by(*raw_priorities)
      @priorities = raw_priorities.map { |raw_priority| Priora::PriorityBuilder.build(raw_priority) }
    end
  end
end
