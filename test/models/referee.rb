class Referee
  include Mongoid::Document

  field :name
  field :can_fly, :type => Boolean

  has_many :matches

end