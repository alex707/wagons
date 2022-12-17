# phonogram = Phonogram.find(15)
# phonogram.flush
# TranscriberFlow.new(phonogram).call

# loop do
#   Phonograms.where(status: 1).each do |phonogram|
#     TranscriberFlow.new(phonogram).call
#   end
# end

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
