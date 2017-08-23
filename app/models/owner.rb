class Owner < ActiveRecord::Base
  belongs_to :vehicle
  has_many :vehicles
end
