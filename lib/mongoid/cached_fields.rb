module Mongoid
	module CachedFields

		extend ::ActiveSupport::Concern

		included do
			class_attribute :cached_fields
			self.cached_fields = []

			before_save :update_cached_fields

			class_attribute :nested_cached_fields
			self.nested_cached_fields = []
		end

		module ClassMethods

			def cached_field(name, options = {})
				field name, options

				self.cached_fields << name

				cache_method = "cache_#{name}".to_sym
				callback = options[:value]

				# intance method wich updates the cached field
				define_method cache_method do
					self.send("#{name}=", self.instance_eval(&callback))
				end
			end

			def cached_fields_for(name)
				self.nested_cached_fields << name

				cache_method = "cache_nested_#{name}".to_sym

				assoc = self.reflect_on_association(name)

				define_method cache_method do

					# TODO: fix this
					# Update cached values of old document if foreign_key changed (Only on external has_one documents)
					# if !new_record? and !assoc.many? and !assoc.embedded? and self.send("#{assoc.foreign_key}_changed?") and prev_val = self.send("#{assoc.foreign_key}_was")
					# 	assoc.klass.find(prev_val).try do |r|
					# 		r.update_cached_fields
					# 		r.save
					# 	end
					# end

					[*self.send(name)].each do |r|
						r.try do |r|
							r.update_cached_fields
							r.save unless assoc.embedded?
						end
					end
				end

				if assoc.embedded?
					before_save cache_method
				else
					after_save cache_method
				end
			end

			def update_cached_fields!
				all.each do |r|
					r.save
				end

				true
			end

		end

		module InstanceMethods
			def update_cached_fields
				self.cached_fields.each do |name|
					cache_method = "cache_#{name}".to_sym
					self.send cache_method
				end
			end
		end

	end
end