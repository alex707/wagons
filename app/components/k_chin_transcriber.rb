class KChinTranscriber
  attr_reader :phonogram

  def initialize(phonogram)
    @phonogram = phonogram
  end

  def call
    return if phonogram.status < 3
    return if phonogram.status == 7

    script_exec(phonogram.parsed_text)
    upload_csv
  end

  private

  def script_exec(text_as_a_param)
    phonogram.update(status: 4)

    File.write(
      "tmp/csvs/#{phonogram.source_sound.key}.csv",
      `python3 external/transcriber.py \"#{text_as_a_param}\"`,
      mode: 'w'
    )
  end

  def upload_csv
    phonogram.parsed_csv.attach(
      io: File.open("tmp/csvs/#{phonogram.source_sound.key}.csv"),
      filename: "#{phonogram.source_sound.key}.csv" ,
      content_type: 'text/csv'
    )

    flush

    phonogram.update(status: 5)
  end

  def flush
    FileUtils.rm_rf Dir.glob('tmp/csvs/*.csv')
  end
end
