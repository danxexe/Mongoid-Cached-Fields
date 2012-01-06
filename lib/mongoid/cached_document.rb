module Mongoid

  # TODO: this class should act more like a proxy
  class CachedDocument
    include Mongoid::Document

    class_attribute :cached_fields
    class_attribute :cache_from

    self.cached_fields = []

    after_build :add_cached_fields

    def _source
      _parent.try(_class.cache_from)
    end
    alias_method :_class, :class


    def update_cache
      self.attributes = _source.attributes.reject { |k,v| _class.cached_fields.exclude? k }
      self._id = _source._id
    end

    def reload
      update_cache
      self
    end

    private

    def add_cached_fields
      _class.cached_fields.each do |name|
        self._class.field name, _source.fields[name].options
      end
    end

  end
end