class PhonogramsController < ApplicationController
  before_action :set_phonogram, only: %i[ show edit update destroy ]

  # GET /phonograms or /phonograms.json
  def index
    @phonograms = Phonogram.all
  end

  # GET /phonograms/1 or /phonograms/1.json
  def show
  end

  # GET /phonograms/new
  def new
    @phonogram = Phonogram.new
  end

  # GET /phonograms/1/edit
  def edit
  end

  # POST /phonograms or /phonograms.json
  def create
    @phonogram = Phonogram.new(phonogram_params)
    @phonogram.source_sound.attach(phonogram_params[:source_sound])

    YaSpeechKit::Uploader.new(phonogram).call

    respond_to do |format|
      if @phonogram.save
        @phonogram.update(status: 1) if @phonogram.source_sound.attached?
        format.html { redirect_to phonogram_url(@phonogram), notice: "Phonogram was successfully created." }
        format.json { render :show, status: :created, location: @phonogram }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @phonogram.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phonograms/1 or /phonograms/1.json
  def update
    @phonogram.source_sound&.destroy
    @phonogram.parsed_csv&.destroy
    @phonogram.source_sound.attach(phonogram_params[:source_sound])

    phonogram.flush
    YaSpeechKit::Uploader.new(phonogram).call

    respond_to do |format|
      if @phonogram.valid?
        format.html { redirect_to phonogram_url(@phonogram), notice: "Phonogram was successfully updated." }
        format.json { render :show, status: :ok, location: @phonogram }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @phonogram.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phonograms/1 or /phonograms/1.json
  def destroy
    @phonogram.source_sound&.destroy
    @phonogram.parsed_csv&.destroy
    @phonogram.destroy

    respond_to do |format|
      format.html { redirect_to phonograms_url, notice: "Phonogram was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phonogram
      @phonogram = Phonogram.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def phonogram_params
      params.require(:phonogram).permit(:source_sound, :user_id)
    end
end
