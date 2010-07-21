require 'socket.so'

class UDPServer
  def initialize(port)
    @port = port
  end

  def start
    @socket = UDPSocket.new
    @socket.bind(nil, @port)
    while true
      packet = @socket.recvfrom(1024)
      puts packet
    end
  end
end

server = UDPServer.new(9000)
server.start

