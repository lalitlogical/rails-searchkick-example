# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

(1..5000).each do |i|
  brand = [:samsung, :apple, :huwai, :mi, :oneplus, :oppo, :vivo, :motorola, :jbl, :boat, :honor, :asus].sample
  MobilePhone.create!(
    name: "#{brand.to_s.humanize} #{Faker::App.name}",
    description: Faker::Lorem.paragraphs(4).join(' '),
    brand: brand,
    price: Faker::Number.between(6000, 85000),
    ram: Faker::Number.between(1, 8),
    screen_size: Faker::Number.between(1, 6) * 1.25,
    sim_type: [:dual_sim, :single_sim, :four_sim].sample,
    primary_camera: Faker::Number.between(1, 20),
    secondary_camera: Faker::Number.between(1, 20),
    battery: Faker::Number.between(1500, 4500),
    avatar: Faker::Avatar.image
  )
end
