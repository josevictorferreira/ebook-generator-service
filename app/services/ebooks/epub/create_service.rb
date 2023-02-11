# frozen_string_literal: true

module Ebooks
  module Epub
    class CreateService
      attr_reader :title, :content, :cover_image

      include ApplicationService

      FILE_FORMAT = '.epub'

      ValidationSchema = Dry::Schema.Params do
        required(:title).filled(:str?)
        required(:content).filled(:str?)
      end

      def call(params)
        @content = params[:content]
        @title = params[:title]
        @cover_image = params[:cover_image]
        generate_epub_file!
      end

      private

      def book
        @book ||= GEPUB::Book.new
      end

      def generate_epub_file!
        set_file_defaults!
        set_cover_image!
        set_file_contents!
        file = filename(@title)
        content = book.generate_epub(file)
        Success(filename: file, content:)
      end

      def set_cover_image!
        return if @cover_image.blank?

        cover_image_file = URI.open(@cover_image)

        book.add_item('img/cover_image.jpg', content: @cover_image_file).cover_image
      end

      def set_file_defaults!
        book.language = 'en'
        book.creator = 'J0S3V1'
        book.add_title @title,
                        title_type: GEPUB::TITLE_TYPE::MAIN,
                        lang: 'en',
                        file_as: @title,
                        display_seq: 1
      end

      def set_file_contents!
        book.ordered do
          item = book.add_item('text/chap1.xhtml')
          item.add_content StringIO.new(content_with_title)
          item.toc_text @title
        end
      end

      def filename(file_name)
        "#{file_name.parameterize.underscore}#{FILE_FORMAT}"
      end

      def content_with_title
        "<h1>#{@title}</h1>#{@content}"
      end
    end
  end
end
