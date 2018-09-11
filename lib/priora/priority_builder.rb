require_relative 'priority'

module Priora
  class PriorityBuilder
    class << self
      def build(raw_priority)
        case raw_priority
        when Symbol
          Priority.new(attribute: raw_priority)
        when Array
          priority_hash = raw_priority.reduce(:merge)
          build_from_hash(priority_hash)
        when Hash
          build_from_hash(raw_priority)
        else
          raise InvalidPrioritySyntaxError
        end
      rescue StandardError => e
        raise InvalidPrioritySyntaxError
      end

      private

      def build_from_hash(priority_hash)
        unless priority_hash.one?
          raise InvalidPrioritySyntaxError, 'directional priority declaration takes only a single priority at a time!'
        end

        attribute = priority_hash.keys.first
        direction = priority_hash[attribute]

        Priority.new(attribute: attribute, direction: direction)
      end
    end
  end
end
