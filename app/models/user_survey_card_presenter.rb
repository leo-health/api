class UserSurveyCardPresenter
  def initialize(user_survey:, card_id:)
    @color = "#FF5F40"
    @icon = nil #Leo::Entities::ImageEntity.represent(CardIcon.survey.icon)

    @user_survey = user_survey
    @card_id = card_id
  end

  def present
    card_id = @card_id
    current_state = present_begin_survey

    {
      card_id: card_id,
      card_type: "survey",
      associated_data: Leo::Entities::UserSurveyEntity.represent(@user_survey),
      current_state: current_state,
      states: [
        current_state
      ]
    }
  end

  def present_begin_survey
    user_survey_id = @user_survey.id
    color = @color
    icon = @icon

    body_text = "You have a new survey to fill out"
    if patient_first_name = @user_survey.patient.try(:first_name)
      body_text += " about #{patient_first_name}"
    end

    {
      card_state_type: "BEGIN_SURVEY",
      title: "Fill out a survey!",
      icon: icon,
      color: color,
      tinted_header: "MCHAT",
      body: body_text,
      footer: "Something cool goes here",
      button_actions: [
        {
          display_name: "BEGIN SURVEY",
          action_type: "BEGIN_SURVEY",
          payload: {
            user_survey_id: user_survey_id
          }
        }
      ]
    }
  end
end
