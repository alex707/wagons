class Transcriber
  PROVIDER = :ya

  attr_reader :phonogram

  def initialize(phonogram)
    @phonogram
  end

  def call
    case PROVIDER
    when :ya
      YaSpeechKit::Uploader.new(phonogram).call
      YaSpeechKit::Transcriber.new(phonogram).call
    end
  end

  private

end
