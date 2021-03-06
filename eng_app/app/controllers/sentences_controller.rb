
require "word_meaning_service.rb"

class WMChache

  attr_accessor :cache

  def initialize
    @cache = {}
  end

  def update(sentence)
    return unless need_update?(sentence)
    @cache[sentence.no] = 
        {date: Time.now,
         data: WordMeaningService.new.get(sentence)}
  end

  def presenter(sentence)
    return nil if @cache[sentence.no].blank?
    WordMeaningPresenter.new(@cache[sentence.no][:data])
  end

protected

  def need_update?(sentence)
    no = sentence.no
    if @cache[no].present? && 
       (Time.now - @cache[no][:date]) >= 1.days
      return true
    end
    if @cache[no].blank?
      return true
    end
    return false
  end
end

class SentencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sentence, only: [:show, :edit, :update, :destroy]

  PER = 5

  # GET /sentences
  # GET /sentences.json
  def index
    @sentences = current_user.view_model.sentences_with_pagenate(params[:page], PER)
  end

  # GET /sentences/1
  # GET /sentences/1.json
  def show
    @wm_cache = WMChache.new if defined?(@wm_cache).nil?
    @wm_cache.update(@sentence)
    @wmp = @wm_cache.presenter(@sentence)
  end

  # GET /sentences/new
  def new
    @sentence = Sentence.new
  end

  # GET /sentences/1/edit
  def edit
  end

  # GET /sentences/search
  def search
    @sentence = Sentence.find_by_no(params[:no])
    respond_to do |format|
      if @sentence
        format.html { redirect_to @sentence, notice: '' }
      else
        @sentence = Sentence.find_by_no(1)
        format.html { redirect_to @sentence, notice: '' }
      end
    end
  end

  # POST /sentences
  # POST /sentences.json
  def create
    @sentence = Sentence.new(sentence_params)

    respond_to do |format|
      if @sentence.save
        format.html { redirect_to @sentence, notice: 'Sentence was successfully created.' }
        format.json { render :show, status: :created, location: @sentence }
      else
        format.html { render :new }
        format.json { render json: @sentence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sentences/1
  # PATCH/PUT /sentences/1.json
  def update
    respond_to do |format|
      if @sentence.update(sentence_params)
        format.html { redirect_to @sentence, notice: 'Sentence was successfully updated.' }
        format.json { render :show, status: :ok, location: @sentence }
      else
        format.html { render :edit }
        format.json { render json: @sentence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sentences/1
  # DELETE /sentences/1.json
  def destroy
    @sentence.destroy
    respond_to do |format|
      format.html { redirect_to sentences_url, notice: 'Sentence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def self.list_sentences(user_id)
    user = nil
    res = nil
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find_by_id(user_id)
      raise "user #{user_id} not found" unless user
      res = user.view_model.sentences.map{|s| {no: s[0].no, score: s[1]}}
    end
    return res
  end 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sentence
      @sentence = Sentence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sentence_params
      params.require(:sentence).permit(:no, :en, :jp, :voice_data)
    end
end
