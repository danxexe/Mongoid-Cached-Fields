module Mongoid
  module CachedFields

    class CachedDocumentProxy < ActiveSupport::BasicObject

      attr_reader :parent, :source, :cache

      def initialize(parent, relation_name)
        @parent = parent
        @relation_name = relation_name.to_s
        @source = parent.send("source_#{relation_name}")
        @cache = parent.send("cached_#{relation_name}")

        build_cache
        update_cache
      end

      def class
        parent.relations[@relation_name].klass
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
        cache.attributes = source.attributes.reject { |k,v| cache.cached_fields.exclude? k.to_s }
        cache._id = source._id
      end

    end

  end
end