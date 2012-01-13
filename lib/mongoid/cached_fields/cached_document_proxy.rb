module Mongoid
  module CachedFields

    class CachedDocumentProxy < ActiveSupport::BasicObject

      attr_reader :cached_relation, :parent

      def initialize(cached_relation, parent, relation_name)
        @cached_relation = cached_relation
        @parent = parent
        @relation_name = relation_name.to_s
      end

      def class
        parent.relations[@relation_name].klass
      end

      def source
        @source ||= parent.send("source_#{@relation_name}")
        @source
      end

      def cache
        @cache ||= parent.send("cached_#{@relation_name}")
        @cache
      end

      def cache=(val)
        parent.send(cached_relation.relation_name(:set_cache), val)
      end

      def target(m)
        if cached_relation.relation_meta(:original).many? && m.to_s == '[]'
          cache
        elsif cache && cache.cached_fields.include?(m.to_s)
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
        @cache = parent.send(build_cached_relaction_method) unless cache
      end

      def update_cache
        cache_class = cached_relation.relation_class(:cache)

        if cached_relation.relation_meta(:original).many?
          self.cache = source.map do |source_doc|
            cache_doc = cache_class.new
            cache_doc.attributes = source_doc.attributes.reject { |k,v| cache_class.cached_fields.exclude? k.to_s }
            cache_doc.id = source_doc.id

            cache_doc
          end
        else
          build_cache
          cache.attributes = source.attributes.reject { |k,v| cache_class.cached_fields.exclude? k.to_s }
          cache.id = source.id
        end
      end

    end

  end
end