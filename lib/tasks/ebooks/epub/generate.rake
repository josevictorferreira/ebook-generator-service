# frozen_string_literal: true

namespace :ebooks do
  namespace :epub do
    desc 'Generate a EPUB file for a given URL'
    task generate: :environment do
      url = ENV.fetch('URL', nil)
      Articles::ParserService.call(url:) do |service_result|
        service_result.success do |result|
          Ebooks::Epub::CreateService.call(result) do |res|
            res.success do |epub_result|
              filename = epub_result[:filename]
              puts "#{filename} generated."
            end

            res.failure do
              binding.pry
              puts 'Error generating the EPUB file.'
            end
          end
        end

        service_result.failure do |_result|
          puts 'Error requesting the URL.'
        end
      end
    end
  end
end
