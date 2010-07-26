require 'fileutils'
require 'ftools'
require 'yaml'
require 'socket'
require 'singleton'

require 'pp'

module AniDB
  class Session
    
    def initialize
      @config = AniDB::Config.new
      
      @connection = UDPSocket.new()
      @connection.bind(0, @config[:localport])
    end

    def connect
      response = send(:AUTH,  :user => @config[:username],
                              :pass => @config[:password],
                              :client => 'anidbrb',
                              :clientver => 3,
                              :protover => 3,
                              :enc => 'utf8',
                              :nat => @config[:nat] ? '1' : '0' )
      pp response
      if ok_responses.include? response[0]
        response[1].split.first
      else
        nil
      end
    end

    def send(command, args = {})
      @connection.connect(@config[:hostname], @config[:hostport])
      com = command.to_s + " "
      args.map{ |k,v| com << "#{k.to_s}=#{v}&" }
      com << "sess=#{connect}" unless exempt_commands.include? command
      com.chomp!("&")
      puts "send => Command: #{com}"

      @connection.puts(com)
      puts @connection.recvfrom(1400)[0].split(' ', 2)
      
    end

    def exempt_commands
      [:PING, :AUTH]
    end
  end
end
