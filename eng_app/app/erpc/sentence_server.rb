require 'grpc'
require 'erpc/sentence_services_pb.rb'
require 'erpc/sentence_pb.rb'

require './app/controllers/sentences_controller.rb'

class SentenceServer < Erpc::SentenceService::Service

  def list_sentences(user, _unused_call)
    puts "test calling active model" 
    res = ::SentencesController.list_sentences(user.id).map{|s| Erpc::Sentence.new(s)}
    return Erpc::Sentences.new(sentences: res)
  end
end
