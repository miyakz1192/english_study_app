
require "open-uri"

class WordMeaningService

  def initialize
    @uri = "http://eng-app-wm-app-service:3000/words"
  end

  def get(sentence)
    JSON.load(open("#{@uri}/#{sentence.no}").read)
  end
end
