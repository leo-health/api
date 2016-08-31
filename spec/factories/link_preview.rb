FactoryGirl.define do
  factory :link_preview do
    title "Read this!"
    body "Check out some great content"
    tint_color_hex "#FF5F40"
    tinted_header_text "Header"
    dismiss_button_text "DISMISS"
    deep_link_button_text "SOME LINK"

    trait :notification do
      notification_message "get notified!"
    end

    trait :referral do
      title "Sharing is caring!"
      body "Invite your friends to a private consult at Flatiron Pediatrics"
      tint_color_hex "#FF5F40"
      tinted_header_text "Refer"
      dismiss_button_text "DISMISS"
      deep_link_button_text "REFER A FRIEND"
      deep_link "referral"
      category "referral"
    end

    trait :milestone_content do
      title "Congratulations!"
      body "Happy nth birthday!"
      tint_color_hex "#FF5F40"
      tinted_header_text "READ"
      dismiss_button_text "DISMISS"
      deep_link_button_text "Read"
      external_link "http://www.mumsnet.com/Talk/pedants_corner/584252-you-know-those-ballons-that-say-happy-nth-birthday"
      category "milestone_content"
    end
  end
end
