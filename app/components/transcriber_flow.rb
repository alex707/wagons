# phonogram = Phonogram.find(13)
# phonogram.flush
# TranscriberFlow.new(phonogram).call

class TranscriberFlow
  PROVIDER = :ya

  attr_reader :phonogram

  def initialize(phonogram)
    @phonogram = phonogram
  end

  def call
    case PROVIDER
    when :ya
      YaSpeechKit::Uploader.new(phonogram).call
      YaSpeechKit::Transcriber.new(phonogram).call
      KChinTranscriber.new(phonogram).call
    end
  end
end
