require 'faraday'

# Authorization: Api-Key AQVNyQxmJJVJRSDMkzNk-5Zt1O9MnMFwvaEamZhY
# POST https://transcribe.api.cloud.yandex.net/speech/stt/v2/longRunningRecognize
# {
#     "config": {
#         "specification": {
#             "languageCode": "ru-RU",
#             "model": "general",
#             "profanityFilter": "false",
#             "literature_text": "true",
#             "audioEncoding": "LINEAR16_PCM",
#             "sampleRateHertz": 48000
#         }
#     },
#     "audio": {
#         "uri": "https://storage.yandexcloud.net/wagonhack22-bucket3/711sgxjri5mt7i5e7go3uchj4wto"
#     }
# }

module YaSpeechKit
  class Uploader
    ENGINE_URL = 'https://transcribe.api.cloud.yandex.net'.freeze
    ENGINE_PATH = '/speech/stt/v2/longRunningRecognize'.freeze
    BUCKET_NAME = 'wagonhack22-bucket3'.freeze

    attr_reader :phonogram

    def initialize(phonogram)
      @phonogram = phonogram
    end

    def call
      return unless phonogram.task_uuid.to_s.empty?
      return if phonogram.status == 7

      if request.success?
        phonogram.update(status: 2, task_uuid: response_body.try(:[], 'id'))
      else
        Rails.logger.error 'an error occured in transcribition'

        phonogram.update(status: 7)

        raise request.inspect
      end
    end

    private

    def source_format
      source_format = if phonogram.source_sound.blob.filename.to_s.downcase.end_with?('wav')
        'LINEAR16_PCM'
      elsif phonogram.source_sound.blob.filename.to_s.downcase.end_with?('mp3')
        'MP3'
      else
        'OGG_OPUS'
      end
    end

    def options
      options = {
        config: {
          specification: {
            languageCode: 'ru-RU',
            model: 'general',
            profanityFilter: false,
            literature_text: true,
            audioEncoding: source_format,
            # sampleRateHertz: 48000,
            sampleRateHertz: source_format == 'LINEAR16_PCM' ? 48000 : 44100,
          }
        },
        audio: {
          uri: "https://storage.yandexcloud.net/#{BUCKET_NAME}/#{phonogram.source_sound.key}"
        }
      }
    end

    def params
      params = {}
    end

    def connection
      @connection ||= Faraday.new(url: ENGINE_URL) do |c|
        c.use Faraday::Request::UrlEncoded
        c.use Faraday::Response::Logger
        # c.use Faraday::Adapter::NetHttp
      end
    end

    def request
      @request ||= connection.post ENGINE_PATH, params do |request|
        request.headers['Content-Type'] = 'application/json'
        request.headers['Authorization'] = "Api-Key #{ENV['YC_SK_SECRET_ACCESS_KEY']}"
        request.body = JSON.generate(options)
      end
    end

    def response_body
      unless request.success?
        phonogram.update(status: 7)

        raise request.inspect
        return
      end

      JSON.parse(request.body)
    end
  end
end
