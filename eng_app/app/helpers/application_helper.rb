module ApplicationHelper
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
end
