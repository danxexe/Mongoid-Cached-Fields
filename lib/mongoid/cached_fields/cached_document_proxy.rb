module Mongoid
  module CachedFields

    class CachedDocumentProxy < ActiveSupport::BasicObject

      def initialize(parent, relation_name)
        @parent = parent
        @relation_name = relation_name.to_s
      end

      def class
        parent.relations[@relation_name].klass
      end

      def parent
        @parent
      end

      def source
        @source ||= parent.send("source_#{@relation_name}")
        @source
      end

      def cache
        @cache ||= parent.send("cached_#{@relation_name}")
        @cache
      end

      def target(m)
        if cache && cache.cached_fields.include?(m.to_s)
          cache
        else
          source
        end
      end

      def method_missing(m, *args, &block)
        target(m).send(m, *args, &block)
      end
      def respond_to?(m, include_private = false)
        target(m).respond_to?(m, include_private)
      end


      def build_cache
        build_cached_relaction_method = "build_cached_#{@relation_name}"
        @cache = parent.send(build_cached_relaction_method) unless @cache
      end

      def update_cache
        build_cache

        cache.attributes = source.attributes.reject { |k,v| cache.cached_fields.exclude? k.to_s }
        cache._id = source._id
      end

    end

  end
end