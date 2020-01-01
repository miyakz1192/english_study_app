class ApplicationController < ActionController::Base
  before_action :set_request_from

    # どこのページからリクエストが来たか保存しておく
  def set_request_from
    if session[:request_from]
      @request_from = session[:request_from]
    end
    # 現在のURLを保存しておく
    session[:request_from] = request.original_url
  end

  # 前の画面に戻る
  def return_back
    if request.referer
      redirect_to request.referer and return true
    elsif @request_from
      redirect_to @request_from and return true
    end
  end

  def return_back_url
    if request.referer
      return request.referer
    elsif @request_from
      return @request_from
    end
  end


  helper_method :return_back
  helper_method :return_back_url
end
