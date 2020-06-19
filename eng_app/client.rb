this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, './lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

puts $LOAD_PATH.grep /erpc/


require 'grpc'
require 'erpc/sentence_services_pb.rb'

def main
  puts "start client"
  stub = Erpc::SentenceService::Stub.new('localhost:50051', :this_channel_is_insecure)
  u = Erpc::User.new({id: 1})

  sentence = stub.list_by_worst(u) # ERRRO
  p "output=#{sentence.inspect}"

  puts "end client"
end

main

