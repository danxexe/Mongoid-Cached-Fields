require 'helper'

class TestMongoidCachedFields < Test::Unit::TestCase

  should "cache values" do
    user = FactoryGirl.create(:player)
    user.reload

    assert_equal "Dr. Mario", user.full_name
  end

end
