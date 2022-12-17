class Api::V1::PhonogramsController < ApplicationController
  skip_forgery_protection

  def index
    phonograms = Phonogram.all

    render json:(
      phonograms.map { |elem|
        if elem.parsed_csv.attached?
          parsed_csv = Rails.application.routes.url_helpers.rails_blob_path(elem.parsed_csv.blob, disposition: 'preview')
        end

        {
          'phonogram_id' => elem.id,
          'user_id' => elem.user_id,
          'user_name' => elem&.user&.name,
          'status' => elem.status,
          'filename' => elem.source_sound.filename,
          'parsed_csv_link' => parsed_csv,
          'source_sound_link' => Rails.application.routes.url_helpers.rails_blob_path(elem.source_sound.blob, disposition: 'preview')
        }
      }
    )
  end

  def show
    elem = Phonogram.find(params[:id])

    if elem.parsed_csv.attached?
      parsed_csv = Rails.application.routes.url_helpers.rails_blob_path(elem.parsed_csv.blob, disposition: 'preview')
    end

    render json: 
      {
        'phonogram_id' => elem.id,
        'user_id' => elem.user_id,
        'user_name' => elem&.user&.name,
        'status' => elem.status,
        'filename' => elem.source_sound.filename,
        'parsed_csv_link' => parsed_csv,
        'source_sound_link' => Rails.application.routes.url_helpers.rails_blob_path(elem.source_sound.blob, disposition: 'preview')
      }
  end

  def create
    @phonogram = Phonogram.new(user_id: params[:user_id])
    @phonogram.source_sound.attach(params[:source_sound])

    if @phonogram.save
      @phonogram.update(status: 1) if @phonogram.source_sound.attached?

      if @phonogram.parsed_csv.attached?
        parsed_csv = Rails.application.routes.url_helpers.rails_blob_path(@phonogram.parsed_csv.blob, disposition: 'preview')
      end

      YaSpeechKit::Uploader.new(phonogram).call

      render json: {
        'phonogram_id' => @phonogram.id,
        'user_id' => @phonogram.user_id,
        'user_name' => @phonogram&.user&.name,
        'status' => @phonogram.status,
        'filename' => @phonogram.source_sound.filename,
        'parsed_csv_link' => parsed_csv,
        'source_sound_link' => Rails.application.routes.url_helpers.rails_blob_path(@phonogram.source_sound.blob, disposition: 'preview')
      }
    else
      render json: @phonogram.errors, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def phonogram_params
    params.require(:phonogram).permit(:source_sound, :user_id)
  end
end

# Processing by PhonogramsController#create as HTML
# Parameters: {
#   "authenticity_token"=>"[FILTERED]", "phonogram"=>
#     {
#       "source_sound"=> #<ActionDispatch::Http::UploadedFile:0x00007fc32fae31d0
#         @tempfile=#<Tempfile:/var/folders/tm/g6_hhlz129l5rlcqtd20lwkr0000gn/T/RackMultipart20221217-78061-2jkkcj.mp3
#       >,
#         @original_filename="some_rec_1.mp3",
#         @content_type="audio/mpeg",
#         @headers="Content-Disposition: form-data; name=\"phonogram[source_sound]\"; filename=\"some_rec_1.mp3\"\r\nContent-Type: audio/mpeg\r\n">
#   },
#   "commit"=>"Save"
# }

# curl --location --request POST 'http://91.107.35.153:3000/api/v1/phonograms?user_id=2' \
# --header 'Cookie: __profilin=p%3Dt' \
# --form 'source_sound=@"/Users/liveafun/Downloads/some_rec_1.mp3"'
