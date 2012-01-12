class Match
  include Mongoid::Document
  include Mongoid::CachedFields

  belongs_to :referee, :inverse_of => :matches #, :cache => :name


  # TODO: extend mongoid relation macros with a :cache option
  cached_relation :referee, :cache => :name

end