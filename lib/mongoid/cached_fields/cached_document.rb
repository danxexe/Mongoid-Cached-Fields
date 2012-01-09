module Mongoid
  module CachedFields

    class CachedDocument
      include Mongoid::Document

      class_attribute :cached_fields

      self.cached_fields = []

    end

  end
end