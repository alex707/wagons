# phonogram = Phonogram.find(7)
# phonogram.flush
# TranscriberFlow.new(phonogram).call


# t = Time.new(2022, 12, 18, 11, 0, 0, '+03:00')
# loop do
#   Phonogram.where('created_at > ?', t).where(status: 1).each do |phonogram|
#     puts "----->>> started #{phonogram.id}\n"
#     TranscriberFlow.new(phonogram).call
#     puts "----->>> ended #{phonogram.id}\n"
#   end
#   puts "waiting..."
#   sleep 10
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
