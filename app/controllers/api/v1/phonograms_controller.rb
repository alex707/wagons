class Api::V1::PhonogramsController < ApplicationController
  skip_forgery_protection

  def index
    phonograms = Phonogram.all

    render json:(
      phonograms.map { |elem|
        {
          'phonogram_id' => elem.id,
          'data' => elem.data,
          'filename' => elem.source_sound.filename,
          'source_sound_link' => Rails.application.routes.url_helpers.rails_blob_path(elem.source_sound.blob, disposition: 'preview')
        }
      }
    )
  end

  def show
    elem = Phonogram.find(params[:id])

    render json: 
      {
        'phonogram_id' => elem.id,
        'data' => elem.data,
        'filename' => elem.source_sound.filename,
        'source_sound_link' => Rails.application.routes.url_helpers.rails_blob_path(elem.source_sound.blob, disposition: 'preview')
      }
  end

  def create
    @phonogram = Phonogram.new
    @phonogram.source_sound.attach(params[:source_sound])

    if @phonogram.save
      render json: {
        'phonogram_id' => @phonogram.id,
        'data' => @phonogram.data,
        'filename' => @phonogram.source_sound.filename,
        'source_sound_link' => Rails.application.routes.url_helpers.rails_blob_path(@phonogram.source_sound.blob, disposition: 'preview')
      }
    else
      render json: @phonogram.errors, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def phonogram_params
    params.require(:phonogram).permit(:data, :source_sound)
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
