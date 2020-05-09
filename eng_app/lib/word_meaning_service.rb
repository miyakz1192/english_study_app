
require "open-uri"

class WordMeaningService

  def initialize
    @uri = "http://eng-app-wm-app-service:3000/words"
  end

  def get(sentence)
    begin
      JSON.load(open("#{@uri}/#{sentence.no}").read)
    rescue => e
      logger.debug(e)
      return [{"en" => "<<Woops!!>>", "note" => "<<failed with WMS>>", "url" => "http://"} ]
    end
  end
end
