# frozen_string_literal: true

module ApplicationService
  module ClassMethods
    def call(params, &)
      service_outcome = new.call(params)
      if block_given?
        Dry::Matcher::ResultMatcher.call(service_outcome, &)
      else
        service_outcome
      end
    end
  end

  module InstanceMethods
    include Dry::Monads[:result, :do]

    def call(params)
      yield validate_params(params)

      super(params)
    end

    def validate_params(params)
      if self.class.constants.include? :ValidationSchema
        validation_outcome = self.class.const_get(:ValidationSchema).call(params)

        return Failure(validation_outcome.errors.to_h) if validation_outcome.failure?
      end

      Success(params)
    end
  end

  def self.included(klass)
    klass.prepend InstanceMethods
    klass.extend ClassMethods
  end
end
