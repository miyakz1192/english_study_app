class ScoreEngNotWrittensController < ApplicationController
  before_action :set_score_eng_not_written, only: [:show, :edit, :update, :destroy]

  # GET /score_eng_not_writtens
  # GET /score_eng_not_writtens.json
  def index
    @score_eng_not_writtens = ScoreEngNotWritten.all
  end

  # GET /score_eng_not_writtens/1
  # GET /score_eng_not_writtens/1.json
  def show
  end

  # GET /score_eng_not_writtens/new
  def new
    @score_eng_not_written = ScoreEngNotWritten.new
  end

  # GET /score_eng_not_writtens/1/edit
  def edit
  end

  # POST /score_eng_not_writtens
  # POST /score_eng_not_writtens.json
  def create
    @score_eng_not_written = ScoreEngNotWritten.new(score_eng_not_written_params)

    respond_to do |format|
      if @score_eng_not_written.save
        format.html { redirect_to @score_eng_not_written, notice: 'Score eng not written was successfully created.' }
        format.json { render :show, status: :created, location: @score_eng_not_written }
      else
        format.html { render :new }
        format.json { render json: @score_eng_not_written.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /score_eng_not_writtens/1
  # PATCH/PUT /score_eng_not_writtens/1.json
  def update
    respond_to do |format|
      if @score_eng_not_written.update(score_eng_not_written_params)
        format.html { redirect_to @score_eng_not_written, notice: 'Score eng not written was successfully updated.' }
        format.json { render :show, status: :ok, location: @score_eng_not_written }
      else
        format.html { render :edit }
        format.json { render json: @score_eng_not_written.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /score_eng_not_writtens/1
  # DELETE /score_eng_not_writtens/1.json
  def destroy
    @score_eng_not_written.destroy
    respond_to do |format|
      format.html { redirect_to score_eng_not_writtens_url, notice: 'Score eng not written was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_score_eng_not_written
      @score_eng_not_written = ScoreEngNotWritten.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def score_eng_not_written_params
      params.fetch(:score_eng_not_written, {}).permit(:passed, :sentence_id, :user_id)
    end
end
