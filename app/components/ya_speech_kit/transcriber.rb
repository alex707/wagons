require 'faraday'

# curl --location --request GET 'https://operation.api.cloud.yandex.net/operations/e03bh10h111sb4o2d6dj' \
# --header 'Authorization: Api-Key AQVNwBQEiAcjLPEgYZxLqIkUHteArq4b5srdiw2f'

module YaSpeechKit
  class Transcriber
    attr_reader :phonogram, :aggrigate_words

    SKK_ENGINE_URL = 'https://operation.api.cloud.yandex.net'.freeze
    SKK_ENGINE_PATH = '/operations'.freeze

    def initialize(phonogram)
      @phonogram = phonogram
    end

    def call
      return if phonogram.status.to_i < 2

      return unless response_body.any?
      return unless response_body['response']

      phonogram.update(parsed_text: aggrigate_words, status: 3)
    end

    private

    def params
      {}
    end

    def connection
      connection = Faraday.new(url: SKK_ENGINE_URL) do |c|
        c.use Faraday::Request::UrlEncoded
        c.use Faraday::Response::Logger
      end
    end

    def request
      response = connection.get "#{SKK_ENGINE_PATH}/#{phonogram.task_uuid}", params do |request|
        request.headers['Authorization'] = "Api-Key #{ENV['YC_SK_SECRET_ACCESS_KEY']}"
        request.body = JSON.generate({})
      end
    end

    def response_body
      return unless request.success?

      JSON.parse(request.body)
      # JSON.parse(response.body)
    end

    def aggrigate_words
      return '' unless response_body['response']['chunks']&.any?

      @aggrigate_words ||= response_body['response']['chunks'].map do |a|
        a['alternatives'].map do |b|
          b['text']
        end
      end.flatten.join(' ')
    end
  end
end
