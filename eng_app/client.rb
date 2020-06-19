this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, './lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

puts $LOAD_PATH.grep /erpc/


require 'grpc'
require 'erpc/sentence_services_pb.rb'

def main
  stub = SentenceService::Stub.new('localhost:50051', :this_channel_is_insecure)
  u = User.new({id: "1"})

  puts u.class.name
  puts u.class.inspect
  puts u.class.class.name
  puts u.class.class.inspect
  puts u.inspect
  puts u.class.methods.grep /encode/
  stub.list_by_worst(u) # ERRRO
  #stub.list_by_worst({id: "1"})
  #message = stub.list_by_worst(nil).message
  #p "Greeting: #{message}"
end

def main2

  puts "start client"
  stub = Erpc::SentenceService::Stub.new('localhost:50051', :this_channel_is_insecure)
  u = Erpc::User.new({id: "req_from_client_1"})

  puts u.class.name
  puts u.class.inspect
  puts u.class.class.name
  puts u.class.class.inspect
  puts u.inspect
  puts u.class.methods.grep /encode/
  sentence = stub.list_by_worst(u) # ERRRO
  p "output=#{sentence.inspect}"

  puts "end client"
end

main2

