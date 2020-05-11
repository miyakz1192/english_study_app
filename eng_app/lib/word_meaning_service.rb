
require "open-uri"

class WordMeaningService

  def initialize
    @uri = "http://eng-app-wm-app-service:3000/words"
  end

  def get(sentence)
    begin
      JSON.load(open("#{@uri}/#{sentence.no}").read)
    rescue OpenURI::HTTPError => e
      Rails.logger.error ("ERROR in WordMeaningService:get 404 ERROR")
      #404 ERROR
      if ([e.message].grep /404/).size != 0
        return [{"en" => "NO WORDS REGISTERD", "note" => "NO WORDS REGISTERD", "url" => "http://"} ]
      end
    rescue => e
      Rails.logger.error ("ERROR in WordMeaningService:get")
      Rails.logger.error ([e.message]+e.backtrace).join($/)
      return [{"en" => "Woops!!", "note" => "failed with WMS", "url" => "http://"} ]
    end
  end
end
