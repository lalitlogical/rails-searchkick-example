# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# MobilePhone.delete_all

brand = ["Samsung", "Panasonic", "Micromax", "Nokia", "Sony", "Lava", "Adcom", "Blackbear", "BlackBear", "BlackZone", "Blackzone", "BQ", "BSNL", "Callbar", "Celkon", "Champion", "Darago", "Datawind", "Forme", "GAMMA", "Gfive", "Gionee", "Good One", "Haier", "Heemax", "HPL", "HTC", "Huawei", "Iball", "Intex", "Ismart", "Itel", "iVooMi", "Jinga", "Jio", "JIVI", "Kara", "Karbonn", "Kechaoda", "Kimfly", "Lemon", "Lenovo", "Lychee", "LYCHEE", "M-Horse", "MAXX", "Mtech", "nuvo", "Onida", "Peace", "Philips", "RAGE", "Reach", "Reliance", "Rio", "Sansui", "Spice", "Subway", "Swipe", "T-Max", "Tecoze", "Trio", "TYMES", "UI Phones", "Videocon", "Vox", "Wham", "Whitecherry", "XCCESS", "Xolo", "Yxtel", "Zen", "Ziox", "ZOPO", "ZTE", "Acer", "AIEK", "AIRI Mobile", "AK", "Alcatel", "Animate", "Apple", "Asus", "Billion", "Binatone", "Blackberry", "BLU", "Callmate", "Camerii", "CAT", "Cheers", "Colors", "Comio", "Coolpad", "Diamond", "Doel", "Fox", "Gigaset", "Google", "GS", "Hi Tech", "Honor", "HP", "Infinix", "InFocus", "Kenxinda", "Kodak", "LG", "LYF", "Mi", "Microsoft", "Mido", "MOBONE", "Motorola", "Nubia", "Okwu", "OnePlus", "OPPO", "Smartron", "TCL", "Tecno", "TP-Link", "Uniscope", "VIVO", "Voicair", "Voto", "XOLO", "Yu"]

mobile_phones = []
1000000.times do |i|
  sample_brand = brand.sample
  name = "#{sample_brand} #{Faker::App.name} #{Faker::Movie.quote} #{Faker::App.version} #{Time.now.to_i}"
  mobile_phones << MobilePhone.new(
    name: name,
    slug: name.parameterize,
    description: Faker::Lorem.paragraphs(4).join(' '),
    brand: sample_brand,
    price: Faker::Number.between(6000, 85000),
    ram: Faker::Number.between(1, 8),
    screen_size: Faker::Number.between(1, 6) * 1.25,
    sim_type: [:dual_sim, :single_sim, :four_sim].sample,
    primary_camera: Faker::Number.between(1, 20),
    secondary_camera: Faker::Number.between(1, 20),
    battery: Faker::Number.between(1500, 4500),
    avatar: Faker::Avatar.image
  )

  if mobile_phones.length >= 1000
    begin
      MobilePhone.import mobile_phones
    rescue StandardError => e
    end
    mobile_phones = []
  end
end

MobilePhone.import mobile_phones if mobile_phones.present?
MobilePhone.reindex
