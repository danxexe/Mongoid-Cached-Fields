class Match
  include Mongoid::Document
  include Mongoid::CachedFields

  belongs_to :referee, :inverse_of => :matches #, :cache => :name

  has_many :players, :inverse_of => :matches #, :cache => [:name, :full_name]



  # Manual cache

  class CachedReferee
    include Mongoid::Document

    embedded_in :match

    CACHE_ATTRIBUTES = ['name']
    CACHE_CLASS = Referee

    # TODO: delegate missing attributes to non-cached instance
    # def method_missing(m, *args, &block)
    #   match.referee.send(m, *args, &block)
    # end
    # def respond_to?(m, include_private = false)
    #   match.referee.respond_to?(m, include_private)
    # end

    def reload
      match.update_cache_referee
      self
    end

    CACHE_ATTRIBUTES.each do |name|
      add_field name, CACHE_CLASS.fields[name].options
    end

  end

  embeds_one :cache_referee, :class_name => 'Match::CachedReferee'

  before_save :update_cache_referee

  def update_cache_referee

    if self.referee.present?
      self.build_cache_referee unless self.cache_referee.present?
      self.cache_referee.attributes = self.referee.attributes.reject { |k,v| Match::CachedReferee::CACHE_ATTRIBUTES.exclude? k }
    else
      self.cache_referee = nil
    end
  end

  # cached_field :referee_name, :value => proc { referee.try(:name) }

end