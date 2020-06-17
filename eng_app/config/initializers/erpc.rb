puts "DEBUG: entring grpc!!!"
s = GRPC::RpcServer.new

puts "DEBUG: now add http2 port"
s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)

puts "DEBUG: entring handle"
s.handle(SentenceServer)

puts "DEBUG: handle complete"
# Runs the server with SIGHUP, SIGINT and SIGQUIT signal handlers to 
#   gracefully shutdown.
# User could also choose to run server via call to run_till_terminated
puts "DEBUG: run_till_terminated_or_interrupted"

#s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])

Thread.new do
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end


#module GRPC
#  extend Logging.globally
#end
#
#Logging.logger['GRPC'].level = :debug
#

puts "DEBUG: grpc done!!!"
