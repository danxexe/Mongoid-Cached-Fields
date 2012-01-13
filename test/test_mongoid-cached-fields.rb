require 'helper'

class TestMongoidCachedFields < Test::Unit::TestCase

  should "cache simple values" do
    user = Factory(:player_mario)
    user.reload

    assert_equal "Dr. Mario", user.full_name
  end

  should "cache has_one association values" do
    match = Factory(:match)
    match = match.class.find(match.id)

    assert_equal "Lakitu", match.referee.name
  end

  should "not hit the database when reading has_one cached values" do
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

  should "cache has_many association values" do
    team = Factory(:team_mario)
    team = team.class.find(team.id)

    assert_equal "Mario", team.players[0].name
    assert_equal "Luigi", team.players[1].name
  end

  should "not hit the database when reading has_many cached values" do
    team = Factory(:team_mario)
    team = team.class.find(team.id)

    log_count[:find] = 0

    team.players[0].name

    assert_equal 0, log_count[:find]
  end

  should "forward non-cached values to the source document on has_many relations" do
    team = Factory(:team_mario)
    team = team.class.find(team.id)

    assert_equal "Dr.", team.players[0].title
    assert_nil team.players[1].title
  end

  should "cache belongs_to association values" do
    team = Factory(:team_mario)
    player = Player.find(team.players[0].id)

    assert_equal "Mario Bros.", player.team.name
  end

  should "not hit the database when reading belongs_to cached values" do
    team = Factory(:team_mario)
    player = Player.find(team.players[0].id)

    log_count[:find] = 0

    player.team.name

    assert_equal 0, log_count[:find]
  end

end
