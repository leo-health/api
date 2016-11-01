class SeedCardIcons
  def self.seed

    card_types = %w(conversation appointment)

    card_types.map do |card_type|
      CardIcon.update_or_create!(:card_type, {
        card_type: card_type,
        icon: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', "icon-Card-#{card_type}.png"))
      })
    end

    count = CardIcon.count
    puts "Finished seeding #{count} card icons"
  end
end
