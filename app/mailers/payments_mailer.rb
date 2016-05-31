require 'stripe'
class PaymentsMailer < MandrillMailer::TemplateMailer
  default from: 'payments@leohealth.com'

  def new_payment_method(user)
    byebug
    mandrill_mail(
      template: 'Leo - New Payment Method',
      subject: 'Leo - You have enrolled a new payment method.',
      to: user.unconfirmed_email || user.email,
      vars: {
        'FIRST_NAME': user.first_name,
      }
    )
  end

  def invalid_payment_method(user)
    mandrill_mail(
      template: 'Leo - Invalid Credit Card',
      subject: 'Leo - Your credit card is invalid, please call us.',
      to: user.unconfirmed_email || user.email,
      vars: {
        'FIRST_NAME': user.first_name,
      }
    )
  end

  def subscription_updated(user)
    customer_id = user.family.stripe_customer_id
    subscription = user.family.stripe_subscription
    subscription_plan = subscription[:plan][:id]

    invoice = Stripe::Invoice.upcoming(
      customer: customer_id,
      subscription_prorate: true,
      subscription_plan: subscription_plan,
      subscription_quantity: subscription[:quantity]
    )

    line_items = invoice.lines.data
    subscription_amount = 0
    prorated_amount = 0
    line_items.each do |line_item|
      if line_item.try :prorated
        prorated_amount += line_item.amount
      else
        subscription_amount += line_item.amount
      end
    end

    subscription_amount = user.family.stripe_subscription

    byebug

    mandrill_mail(
      template: 'Leo - Invite a Secondary Guardian',
      subject: "You've been invited to join Leo + Flatiron Pediatrics!",
      to: enrollment.email,
      vars: {
        "FIRST_NAME": user.first_name,
        "PAYMENT_CHANGE_REASON": payment_change_reason,
        "PRORATED_AMOUNT": prorated_amount,
        "SUBSCRIPTION_AMOUNT": subscription_amount
      }
    )
  end

  def did_unsubscribe(user)
    mandrill_mail(
      template: 'Leo - Unsubscribe Confirmation',
      subject: 'Leo - You have been unsubscribed from Leo.',
      to: user.unconfirmed_email || user.email,
      vars: {
        'FIRST_NAME': user.first_name,
      }
    )
  end
end
