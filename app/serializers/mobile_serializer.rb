class MobileSerializer < ActiveSerializer
  attributes :id, :name, :slug, :description, :brand, :price, :ram, :screen_size, :sim_type, :primary_camera, :secondary_camera, :battery, :avatar
end
