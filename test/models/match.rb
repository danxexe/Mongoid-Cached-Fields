class Match
  include Mongoid::Document
  include Mongoid::CachedFields

  belongs_to :referee, :inverse_of => :matches #, :cache => :name

  has_many :players, :inverse_of => :matches #, :cache => [:name, :full_name]



  # Manual cache

  class CachedReferee < Mongoid::CachedDocument
    self.cached_fields = ['name']
    self.cache_from = :cache_source_referee
  end

  embeds_one :cached_referee, :class_name => 'Match::CachedReferee'
  alias_method :cache_source_referee, :referee
  alias_method :referee, :cached_referee

  before_save :update_cached_referee

  def update_cached_referee

    if cache_source_referee.present?
      build_cached_referee unless cached_referee.present?
      cached_referee.update_cache
    else
      self.cached_referee = nil
    end
  end

end