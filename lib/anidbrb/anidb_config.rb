module AniDB
  class Config < Hash

    @config_dir = ENV['HOME'] + '/.anidb'
    class << self; attr_reader :config_dir; end

    @config_file = Config.config_dir + '/config.yml'
    class << self; attr_reader :config_file; end

    def initialize
      create_config unless config_exists?
      read_config
    end

    def config_exists?
      File.exists? Config.config_file
    end

    def create_config
      dummy_config = File.join(File.dirname(__FILE__), *%w[config.example.yml])
      FileUtils.mkdir Config.config_dir unless File.directory? Config.config_dir
      FileUtils.cp(dummy_config, Config.config_file)
      FileUtils.chmod(0600, Config.config_file)
    end

    def read_config
      YAML.load_file("#{Config.config_dir}/config.yml").each { |k,v|
        self[k.to_sym] = v
      }
    end
  end
end
