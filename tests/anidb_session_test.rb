require 'test_helper'

class AniDBSessionTest < Test::Unit::TestCase

    context "with an existing and valid session" do
      setup do
        file = mock
        File.stubs(:open).returns(file)
        AniDB::Session.any_instance.stubs("session_exists?").returns(true)
      end

      should "restore the session" do
        assert_equal '4567', AniDB::Session.new.session
      end
  end

end
