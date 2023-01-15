# frozen_string_literal: true

module Articles
  class ParserService
    include ApplicationService

    ValidationSchema = Dry::Schema.Params do
      required(:url).filled(:str?)
    end

    def call(params)
      parse_url(params[:url])
    end

    private

    def parse_url(url)
      Typhoeus.get(url).then do |response|
        return Failure('Unable to fetch article.') if response.failure?

        document = Readability::Document.new(response.response_body)

        Success(title: document.title, content: document.content)
      end
    end
  end
end
