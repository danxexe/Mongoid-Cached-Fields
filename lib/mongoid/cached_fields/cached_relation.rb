module Mongoid
  module CachedFields
    class CachedRelation

      def initialize(klass, name, options = {})
        @klass, @name, @options = klass, name, options

        @cached_fields = Array.wrap(@options[:cache]).map(&:to_s)

        cached_document_class!
        cached_relation_macro!
        cached_document_proxy!
        update_cache_callback!
      end

      def source_relation_meta
        @klass.relations[@name.to_s]
      end

      def cached_document_class
        @cached_document_class ||= cached_document_class!
      end


      private

      def cached_document_class!
        parent_class = @klass
        source_class = source_relation_meta.klass
        source_class_name = source_class.name
        cache_class_name = "Cached#{source_class_name}"
        cache_class_cached_fields = @cached_fields
          
        parent_class.module_eval do

          cache_class = Class.new(Mongoid::CachedFields::CachedDocument)

          cache_class.module_eval do
            embedded_in parent_class.name.underscore

            self.cached_fields = cache_class_cached_fields

            self.cached_fields.each do |name|
              field name, source_class.fields[name.to_s].options
            end

          end

          const_set cache_class_name, cache_class

        end

        @cached_document_class = @klass.const_get(cache_class_name)
      end

      def cached_relation_macro!
        cache_relation_name = "cached_#{@name}"
        cache_relation_macro = source_relation_meta.many? ? :embeds_many : :embeds_one
        cache_document_class = cached_document_class.name

        @klass.module_eval do
          send cache_relation_macro, cache_relation_name, :class_name => cache_document_class
        end
      end


      def cached_document_proxy!
        proxy_relation_name = @name
        source_relation_name = "source_#{@name}"
        cache_relation_name = "cached_#{@name}"
        proxy_ivar = "@#{@name}_proxy"

        @klass.module_eval do

          alias_method source_relation_name, proxy_relation_name
          define_method proxy_relation_name do

            instance_variable_get(proxy_ivar) || instance_variable_set(proxy_ivar, Mongoid::CachedFields::CachedDocumentProxy.new(self, proxy_relation_name))

          end

        end
      end

      def update_cache_callback!
        proxy_relation_name = @name
        callback_name = "update_cached_#{@name}"
        source_relation_name = "source_#{@name}"
        cache_relation_name = "cached_#{@name}"
        set_cache_relation_name = "#{cache_relation_name}="
        build_cached_relation_name = "build_#{cache_relation_name}"

        @klass.module_eval do
          
          define_method callback_name do
            if send(source_relation_name)
              send(build_cached_relation_name) unless send(cache_relation_name)
              send(proxy_relation_name).update_cache
            else
              send(set_cache_relation_name, nil)
            end
          end

          before_save callback_name
        end
      end

    end
  end
end