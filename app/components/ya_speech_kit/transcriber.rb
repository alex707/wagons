require 'faraday'

# curl --location --request GET 'https://operation.api.cloud.yandex.net/operations/e03bh10h111sb4o2d6dj' \
# --header 'Authorization: Api-Key AQVNwBQEiAcjLPEgYZxLqIkUHteArq4b5srdiw2f'

module YaSpeechKit
  class Transcriber
    SKK_ENGINE_URL = 'https://operation.api.cloud.yandex.net'.freeze
    SKK_ENGINE_PATH = '/operations'.freeze

    def initialize(phonogram)
      @phonogram = phonogram

      # Ya has very big problems with respond in correct time
      @max_attempts = (@phonogram.source_sound_blob.byte_size.to_i / 1000000 / 5) + 10
    end

    def call
      return if @phonogram.status.to_i < 2

      begin
        attempts ||= 1
        return if attempts > @max_attempts

        Rails.logger.info('')
        Rails.logger.info("attmpt: #{attempts}")

        make_request

        raise if @response_body.empty? || @response_body['done'].to_s != 'true'
      rescue
        if (attempts += 1) < @max_attempts
          puts "task is not done retrying.."
          flush

          retry
        end
      end

      return if !@response_body.key?('response') || !@response_body['response']&.key?('chunks')

      @phonogram.update(parsed_text: aggrigate_words, status: 3)
    end

    private

    def flush
      @connection = nil
      @request = nil
      @response_body = nil

      sleep 5
    end

    def params
      params = {}
    end

    def make_request
      Rails.logger.info("connecting...")
      @connection ||= Faraday.new(url: SKK_ENGINE_URL) do |c|
        c.use Faraday::Request::UrlEncoded
        c.use Faraday::Response::Logger
      end
      Rails.logger.info("connected")

      Rails.logger.info("sending_request...")
      @request ||= @connection.get "#{SKK_ENGINE_PATH}/#{@phonogram.task_uuid}", params do |r|
        r.headers['Authorization'] = "Api-Key #{ENV['YC_SK_SECRET_ACCESS_KEY']}"
        r.body = JSON.generate({})
      end
      Rails.logger.info("request_was_sent")

      if @request.headers["content-length"].to_i < 200 || !@request.success? || JSON.parse(@request.body).nil?
        @response_body = {}
      end

      @response_body ||= JSON.parse(@request.body)
      @response_body
    end

    def aggrigate_words
      return '' unless @response_body['response']['chunks']&.any?

      @aggrigate_words ||= @response_body['response']['chunks'].map do |a|
        a['alternatives'].map { |b| b['text'] }
      end.flatten.join(' ')
    end
  end
end
