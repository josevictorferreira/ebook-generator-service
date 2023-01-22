# frozen_string_literal: true

require 'dry/matcher/result_matcher'

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

        document = Readability::Document.new(response.response_body, tags: %w[h1 h2 h3 h4 h5 h6 div p img],
                                                                     attributes: %w[src h1 h2 h3 h4 h5 h6], remove_empty_nodes: false)

        Success(title: document.title, content: format_content(document.content))
      end
    end

    def format_content(content)
      content
        .gsub(/h3|h4|h5|h6/, 'h2')
    end
  end
end
