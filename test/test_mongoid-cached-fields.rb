require 'helper'

class TestMongoidCachedFields < Test::Unit::TestCase

  should "cache simple values" do
    user = Factory(:player1)
    user.reload

    assert_equal "Dr. Mario", user.full_name
  end

  should "cache association values" do
    match = Factory(:match)
    match.reload

    assert_equal "Lakitu", match.referee.name

    # match.pry
  end

end
