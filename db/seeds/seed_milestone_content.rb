class SeedMilestoneContent
  def self.seed
    ages_for_milestone_content = [1,2,4,6,9,12,15,18,24,36]

    milestone_content_seeds = ages_for_milestone_content.map do |months|
      {
        age_of_patient_in_months: months
      }
    end

    milestone_content_seeds.each do |seed|
      months = seed[:age_of_patient_in_months]
      if months % 12 == 0
        years = months/12
        plural_s = years > 1 ? "s" : ""
        seed[:notification_message] = "Your child is #{years} year#{plural_s} old today. Happy birthday! Here are some suggestions that could be helpful at this milestone."
        seed[:title] = "Your #{years} year old"
        seed[:external_link] = "http://www.leohealth.com/clinical/#{years}-year#{plural_s}"
      else
        plural_s = months > 1 ? "s" : ""
        seed[:notification_message] = "Your child is #{months} month#{plural_s} old today. Here are some suggestions that could be helpful at this milestone."
        seed[:title] = "Your #{months} month old"
        seed[:external_link] = "http://www.leohealth.com/clinical/#{months}-month#{plural_s}"
      end
    end

    icon = Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Icon-Referral.png'))
    milestone_content_seeds.each do |seed|
      seed[:icon] = icon
    end

    milestone_content_seeds.map do |seed|
      LinkPreview.update_or_create!([:category, :title], {
        title: seed[:title],
        body: "Here are some suggestions that could be helpful at this milestone.",
        tint_color_hex: "#CB6FD7",
        tinted_header_text: "Milestones",
        dismiss_button_text: "DISMISS",
        deep_link_button_text: "READ MORE",
        external_link: seed[:external_link],
        icon: seed[:icon],
        age_of_patient_in_months: seed[:age_of_patient_in_months],
        notification_message: seed[:notification_message],
        category: :milestone_content
      })
    end
  end
end
