FactoryGirl.define do

  factory :player1, :class => Player do
    name 'Mario'
    title  'Dr.'
  end

  factory :player2, :class => Player do
    name 'Bowser'
    title  'King'
  end

  factory :referee do
    name 'Lakitu'
    can_fly true
  end

  factory :match do
    referee

    # after_build do |m|
    #   m.referee = Factory(:referee)
    # end

    # players do
    #   [
    #     association(:player1), 
    #     association(:player2)
    #   ]
    # end
  end

end