# frozen_string_literal: true

module Ebooks
  module Epub
    class CreateService
      include ApplicationService

      FILE_FORMAT = '.epub'

      ValidationSchema = Dry::Schema.Params do
        required(:title).filled(:str?)
        required(:content).filled(:str?)
      end

      def call(params)
        generate_epub_file(params)
      end

      private

      def generate_epub_file(params)
        gbook = GEPUB::Book.new do |book|
          book.language = 'en'
          book.creator = 'J0S3V1'
          book.add_title params[:title],
                         title_type: GEPUB::TITLE_TYPE::MAIN,
                         lang: 'en',
                         file_as: params[:title],
                         display_seq: 1
          book.ordered do
            item = book.add_item('text/chap1.xhtml')
            item.add_content StringIO.new(content_with_title(params))
            item.toc_text params[:title]
          end
        end
        file = filename(params[:title])
        content = gbook.generate_epub(file)
        Success(filename: file, content:)
      end

      def filename(file_name)
        "#{file_name.parameterize.underscore}#{FILE_FORMAT}"
      end
    end
  end
end
