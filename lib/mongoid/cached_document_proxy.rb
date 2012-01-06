module Mongoid
  class CachedDocumentProxy < ActiveSupport::BasicObject

    attr_reader :parent, :source, :cache

    def initialize(parent, source, cache)
      @parent, @source, @cache = parent, source, cache
    end

    def class
      source.class
    end

    def method_missing(m, *args, &block)
      if cache && cache.cached_fields.include?(m.to_s)
        target = cache
      else
        target = source
      end

      target.send(m, *args, &block)
    end
    def respond_to?(m, include_private = false)
      super(m, include_private) || _source && _source.respond_to?(m, include_private)
    end

  end
end