FactoryGirl.define do
  factory :conversation do
    association :family, factory: :family
    association { Conversation.participants }
    # association :user_conversations, factory: :user_conversations
    # association :participants, factory: :user
  end
end
