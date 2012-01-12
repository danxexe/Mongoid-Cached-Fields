module Mongoid
  module CachedFields
    class CachedRelation

      attr_reader :cached_fields

      def initialize(klass, name, options = {})
        @klass, @name, @options = klass, name, options

        @cached_fields = Array.wrap(@options[:cache]).map(&:to_s)

        cached_document_class!
        cached_relation_macro!
        cached_document_proxy!
        update_cache_callback!
      end


      def relation_class(target)
        case target
          when :parent then @klass
          when :cache then @cached_document_class ||= cached_document_class!
          else relation_meta(target).klass
        end
      end

      def relation_class_name(target)
        case target
          when :cache then "Cached#{relation_class_name(:original)}"
          else relation_class(target).name
        end
      end

      def relation_name(target)
        case target
          when :original then @name
          when :source then "source_#{relation_name(:original)}"
          when :cache then "cached_#{relation_name(:original)}"
          when :set_cache then "#{relation_name(:cache)}="
          when :proxy then relation_name(:original)
        end
      end

      def relation_meta_name(target)
        case target
          when :source then relation_name(:original)
          else relation_name(target)
        end
      end

      def relation_meta(target)
        relation_class(:parent).relations[relation_meta_name(target).to_s]
      end

      def relation_macro(target)
        case target
          when :cache then relation_meta(:source).many? ? :embeds_many : :embeds_one
          else relation_meta(target).macro
        end
      end

      def proxy(parent)
        Mongoid::CachedFields::CachedDocumentProxy.new(self, parent, relation_name(:original))
      end


      private

      def cached_document_class!
        binding = self
          
        binding.relation_class(:parent).module_eval do

          cache_class = Class.new(Mongoid::CachedFields::CachedDocument).module_eval do
            embedded_in binding.relation_class_name(:parent).underscore, :inverse_of => binding.relation_name(:source)

            self.cached_fields = binding.cached_fields.each do |name|
              field name, binding.relation_class(:source).fields[name.to_s].options
            end

            def _target(m)
              if _index
                 source_collection = relations.first[1][:inverse_of]
                 _parent.send(source_collection)[_index]
              end
            end

            def method_missing(m, *args, &block)
              return super unless _index
              _target(m).send(m, *args, &block)
            end
            def respond_to?(m, include_private = false)
              _target(m).respond_to?(m, include_private)
            end

            self
          end

          const_set binding.relation_class_name(:cache), cache_class

        end
      end

      def cached_relation_macro!
        binding = self

        relation_class(:parent).module_eval do
          send binding.relation_macro(:cache), binding.relation_name(:cache), :class_name => binding.relation_class(:cache).name
        end
      end

      def cached_document_proxy!
        binding = self

        relation_class(:parent).module_eval do

          proxy_ivar = "@#{binding.relation_name(:original)}_proxy"

          alias_method binding.relation_name(:source), binding.relation_name(:original)
          define_method binding.relation_name(:proxy) do
            instance_variable_get(proxy_ivar) || instance_variable_set(proxy_ivar, binding.proxy(self))
          end

        end
      end

      def update_cache_callback!
        binding = self

        callback_name = "update_#{relation_name(:cache)}"
        build_cached_relation_name = "build_#{relation_name(:cache)}"

        @klass.module_eval do
          
          define_method callback_name do
            if send(binding.relation_name(:source))
              send(binding.relation_name(:proxy)).update_cache
            else
              send(binding.relation_name(:set_cache), nil)
            end
          end

          before_save callback_name
        end
      end

    end
  end
end