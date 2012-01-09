class Match
  include Mongoid::Document
  include Mongoid::CachedFields

  belongs_to :referee, :inverse_of => :matches #, :cache => :name

  has_many :players, :inverse_of => :matches #, :cache => [:name, :full_name]


  # TODO: Extract relation cache behaviour

  cached_relation :referee, :cache => :name


  # Manual cache

  before_save :update_cached_referee

  def update_cached_referee

    if referee
      build_cached_referee unless cached_referee
      referee.update_cache
    else
      self.cached_referee = nil
    end
  end

end