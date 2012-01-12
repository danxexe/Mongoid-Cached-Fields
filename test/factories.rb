FactoryGirl.define do

  factory :player_mario, :class => Player do
    name 'Mario'
    title  'Dr.'
  end

  factory :player_luigi, :class => Player do
    name 'Luigi'
  end

  factory :player_bowser, :class => Player do
    name 'Bowser'
    title  'King'
  end

  factory :referee_lakitu, :class => Referee do
    name 'Lakitu'
    can_fly true
  end

  factory :match do
    referee :factory => :referee_lakitu
  end

  factory :team_mario, :class => Team do
    name "Mario Bros."
    players do
      [
        association(:player_mario),
        association(:player_luigi)
      ]
    end
  end

end