require_relative 'priora/version'
require_relative 'priora/configuration'
require_relative 'priora/class_methods'
require_relative 'priora/collection'
require_relative 'priora/priority_builder'
require_relative 'priora/errors'

module Priora
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def included(base_class)
      base_class.extend ClassMethods
    end

    def prioritize(collection, by: nil)
      raw_priorities = by
      priorities = priorities_from_call(collection, raw_priorities)
      Collection.new(collection).prioritize_by(priorities)
    end

    private

    def priorities_from_call(collection, raw_priorities)
      if raw_priorities
        raw_priorities.map { |raw_priority| Priora::PriorityBuilder.build(raw_priority) }
      else
        begin
          collection.map { |item| item.class.priorities }.uniq.first
        rescue StandardError => e
          raise UnsuppliedPrioritiesError
        end
      end
    end
  end
end
