class Team
  include Mongoid::Document
  include Mongoid::CachedFields

  field :name

  has_many :players, :autosave => true

  cached_relation :players, :cache => [:name, :full_name]

end