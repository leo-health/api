class AppointmentCardPresenter
  def initialize(appointment:, card_id:)
    @color = "#5BD998"
    @icon = Leo::Entities::ImageEntity.represent(CardIcon.appointment.icon)

    @appointment = appointment
    @card_id = card_id
  end

  def present
    card_id = @card_id
    current_state = present_appointment_reminder

    {
      card_id: card_id,
      card_type: "appointment",
      associated_data: Leo::Entities::AppointmentEntity.represent(@appointment),
      current_state: current_state,
      states: [
        current_state,
        present_appointment_cancel_unconfirmed,
        present_appointment_cancel_confirmed
      ]
    }
  end

  def present_appointment_reminder
    appointment_id = @appointment.id
    color = @color
    card_id = @card_id
    icon = @icon
    first_name = @appointment.patient.first_name.capitalize
    visit_type = @appointment.appointment_type.name.downcase
    formatted_date = @appointment.start_datetime.strftime("%A, %B %e at %l:%M%P")
    practice_name = @appointment.practice.name
    practice_address = @appointment.practice.address_line_1

    {
      card_state_type: "REMINDER",
      title: "Upcoming Appointment",
      icon: icon,
      color: color,
      tinted_header: first_name,
      body: "#{first_name} has a #{visit_type} scheduled for #{formatted_date}",
      footer: "#{practice_name} • #{practice_address}",
      button_actions: [
        {
          display_name: "CANCEL",
          action_type: "CHANGE_CARD_STATE",
          payload: {
            card_id: card_id,
            next_state_id: "CANCEL_UNCONFIRMED",
            appointment_id: appointment_id
          }
        },
        {
          display_name: "RESCHEDULE",
          action_type: "RESCHEDULE",
          payload: {
            appointment_id: appointment_id
          }
        }
      ]
    }
  end

  def present_appointment_cancel_unconfirmed
    appointment_id = @appointment.id
    color = @color
    card_id = @card_id
    icon = @icon
    first_name = @appointment.patient.first_name.capitalize
    practice_name = @appointment.practice.name
    practice_address = @appointment.practice.address_line_1

    {
      card_state_type: "CANCEL_UNCONFIRMED",
      title: "Cancel Appointment?",
      icon: icon,
      color: color,
      tinted_header: first_name,
      body: "Are you sure you want to cancel your appointment?",
      footer: "#{practice_name} • #{practice_address}",
      button_actions: [
        {
          display_name: "NO",
          action_type: "CHANGE_CARD_STATE",
          payload: {
            card_id: card_id,
            next_state_id: "CANCEL_CONFIRMED"
          }
        },
        {
          display_name: "YES",
          action_type: "CHANGE_CARD_STATE",
          payload: {
            card_id: 0,
            next_state_id: "CANCEL_CONFIRMED",
            appointment_id: appointment_id
          }
        }
      ]
    }
  end

  def present_appointment_cancel_confirmed
    color = @color
    card_id = @card_id
    icon = @icon
    first_name = @appointment.patient.first_name.capitalize
    practice_name = @appointment.practice.name
    practice_address = @appointment.practice.address_line_1

    {
      card_state_type: "CANCEL_CONFIRMED",
      title: "Appointment Cancelled",
      icon: icon,
      color: color,
      tinted_header: first_name,
      body: "#{first_name}'s appointment has been cancelled. This card will be automatically dismissed after some time.",
      footer: "#{practice_name} • #{practice_address}",
      button_actions: [
        {
          display_name: "DISMISS",
          action_type: "DISMISS_CARD",
          payload: {
            card_id: card_id
          }
        }
      ]
    }
  end
end
