require 'fileutils'
require 'ftools'
require 'yaml'
require 'socket'
require 'singleton'

module AniDB

  class Session
    attr_accessor :session_id

    def initialize
      @config_dir = ENV["HOME"] + "/.anidb"
      create_config unless config

      @connection = UDPSocket.new()
      @connection.bind(0, config[:localport])

      session
    end

    def config
      begin
        @config ||= YAML.load_file("#{@config_dir}/config.yml")
      rescue
        return nil
      end
    end

    def create_config
      dummy_config = File.join(File.dirname(__FILE__), *%w[.. .. dummy_config config.example.yml])
      FileUtils.mkdir(@config_dir) unless File.directory?(@config_dir)
      FileUtils.cp(dummy_config, "#{@config_dir}/config.yml")
      FileUtils.chmod(0600, "#{@config_dir}/config.yml" )
      config
    end

    def session
      @session_id = restore_session if session_exists?
      @session_id ||= save_session(connect)
    end

    def session_exists?
      File.exists?(session_file) and File.open(session_file).ctime > (Time.now - 30*60)
    end
    
    def restore_session
      File.open(session_file).readlines.flatten.first
    end

    def save_session(session_id)
      p "Saving Session"
      unless session_id.nil?
        File.open(session_file, "w+") { |file|
          file << session_id
        }
      end
      session_id
    end

    def session_file
      @config_dir + "/session"
    end

    def connect
      p "Connecting to anidb..."
      begin
        response = send(:AUTH,  :user => config[:username],
                                :pass => config[:password],
                                :client => 'anidbrb',
                                :clientver => 2,
                                :protover => 3,
                                :enc => 'utf8',
                                :nat => config[:nat] ? '1' : '0' )
        response = response[0].split[' ']
        puts response.inspect
        if ok_responses.include? response[0]
          response[1]
        else
          nil
        end
      rescue
        response = nil
      end
    end

    def send(command, args = {})
      @connection.connect(config[:hostname], config[:hostport])
      com = command.to_s + " "
      args.map{ |k,v| com << "#{k.to_s}=#{v}&" }
      com << "sess=#{@session_id}" unless exempt_commands.include? command
      com.chomp!("&")
      puts "send => Command: #{com}"
      @connection.puts(com)
      @connection.recvfrom(1400)
    end

    private

    def exempt_commands
      [:PING, :AUTH]
    end

    def ok_responses
      ['200', '201']
    end

  end

end
