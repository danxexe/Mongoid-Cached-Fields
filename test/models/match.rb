class Match
  include Mongoid::Document
  include Mongoid::CachedFields

  belongs_to :referee, :inverse_of => :matches #, :cache => :name

  has_many :players, :inverse_of => :matches #, :cache => [:name, :full_name]



  # Manual cache

  class CachedReferee
    include Mongoid::Document

    class_attribute :cached_fields
    class_attribute :cache_from

    self.cached_fields = ['name']
    self.cache_from = :referee

    after_build :add_cached_fields

    def _cache_source
      _parent.try(cache_from)
    end


    def method_missing(m, *args, &block)
      _cache_source.send(m, *args, &block)
    end
    def respond_to?(m, include_private = false)
      super(m, include_private) || _cache_source && _cache_source.respond_to?(m, include_private)
    end

    def update_cache
      self.attributes = _cache_source.attributes.reject { |k,v| cached_fields.exclude? k }
    end

    def reload
      update_cache
      self
    end

    private

    def add_cached_fields
      cached_fields.each do |name|
        self.class.field name, _cache_source.fields[name].options
      end
    end

  end

  embeds_one :cached_referee, :class_name => 'Match::CachedReferee'

  before_save :update_cached_referee

  def update_cached_referee

    if referee.present?
      build_cached_referee unless cached_referee.present?
      cached_referee.update_cache
    else
      self.cached_referee = nil
    end
  end

end