# frozen_string_literal: true

module Ebooks
  module Epub
    class CreateService
      include ApplicationService

      ValidationSchema = Dry::Schema.Params do
        required(:title).filled(:str?)
        required(:content).filled(:str?)
      end

      def call(params); end
    end
  end
end
