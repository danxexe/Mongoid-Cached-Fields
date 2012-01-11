require 'helper'

class TestMongoidCachedFields < Test::Unit::TestCase

  should "cache simple values" do
    user = Factory(:player1)
    user.reload

    assert_equal "Dr. Mario", user.full_name
  end

  should "cache has_one association values" do
    match = Factory(:match)
    match = match.class.find(match.id)

    assert_equal "Lakitu", match.referee.name
  end

  should "not hit the database when reading cached values" do
    match = Factory(:match)
    match = match.class.find(match.id)

    log_count[:find] = 0

    match.referee.name

    assert_equal 0, log_count[:find]
  end

  should "update cached attribute when set on a new record" do
    match = Factory.build(:match)

    match.referee.name = "Toad"

    assert_equal "Toad", match.referee.name
  end

  should "update cached attribute when set on a existing record" do
    match = Factory.build(:match)

    match.referee.name = "Toad"

    assert_equal "Toad", match.referee.name
  end

end
