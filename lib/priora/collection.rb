module Priora
  class Collection
    def initialize(collection)
      @collection = collection
      @comparison_ready_objects = {}
    end

    def prioritize_by(priorities)
      sorted_collection_by(priorities).reverse
    end

    private

    def sorted_collection_by(priorities)
      @collection.sort do |object_a, object_b|
        comparison_ready(object_a, priorities) <=> comparison_ready(object_b, priorities)
      end
    end

    def comparison_ready(object, priorities)
      @comparison_ready_objects[[object, priorities]] ||= begin
        priorities.map do |priority|
          priority.comparable_value_from(object)
        end
      end
    end
  end
end
