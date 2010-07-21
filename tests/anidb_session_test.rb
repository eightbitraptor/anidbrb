require 'test_helper'

class AniDBSessionTest < Test::Unit::TestCase
  
  @config_dir = ENV['HOME'] + '/.anidb'
  @session_file = @config_dir + 'session'
  
  context "With an already existing session" do
    setup do
      File.stubs(:open).with(@session_file).returns('5678')
    end
    
    should "return the existing session_id" do
      assert '5678', AniDBSession.new.session
    end
  end
  
end