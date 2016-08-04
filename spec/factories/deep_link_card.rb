FactoryGirl.define do
  factory :deep_link_card do
    title "Sharing is caring!"
    body "Invite your friends to a private consult at Flatiron Pediatrics"
    tint_color_hex "#FF5F40"
    tinted_header_text "REFER"
    dismiss_button_text "DISMISS"
    deep_link_button_text "REFER A FRIEND"
    deep_link "referral"
  end
end
