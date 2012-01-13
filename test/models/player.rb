class Player
  include Mongoid::Document
  include Mongoid::CachedFields

  field :name
  field :title

  cached_field :full_name, :value => proc { [title, name].compact.join(' ') }

  belongs_to :team

  cached_relation :team, :cache => :name

end