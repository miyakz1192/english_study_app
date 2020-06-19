require 'grpc'
require 'erpc/sentence_services_pb.rb'
require 'erpc/sentence_pb.rb'

require './app/controllers/sentences_controller.rb'

class SentenceServer < Erpc::SentenceService::Service

  def list_by_worst(user, _unused_call)
    puts "test calling active model" 
    res = ::SentencesController.list_by_worst(user.id).map{|s| Erpc::Sentence.new(s)}
    return res
  end
end
