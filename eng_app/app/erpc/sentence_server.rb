require 'grpc'
require 'erpc/sentence_services_pb.rb'
require 'erpc/sentence_pb.rb'

class SentenceServer < Erpc::SentenceService::Service

  puts "Sentence Server!!!"
  def list_by_worst(user, _unused_call)
    `echo list_by_worst >> /tmp/list_by_worst`
    puts "list_by_worst called!!!"
    puts "user = #{user.inspect}"
    s1 = Erpc::Sentence.new(no:1, data: ["s1"])
    s2 = Erpc::Sentence.new(no:2, data: ["s2"])
    s = Erpc::Sentences.new(sentences: [s1, s2])

    puts "test calling active model" 
    sentences = ::Sentences.all

    #/var/lib/gems/2.5.0/gems/grpc-1.28.0-x86_64-linux/src/ruby/lib/grpc/generic/active_call.rb:31:in `check_status': 2:NameError: uninitialized constant SentenceServer::Sentences (GRPC::Unknown)
    puts "#{sentences.first}"

    return s
    #return Erpc::Sentence.new(no: 1, data: ["h", "e", "l", "l", "o", "!"])
  end
end
