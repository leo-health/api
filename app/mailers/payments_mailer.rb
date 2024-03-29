require 'stripe'
class PaymentsMailer < MandrillMailer::TemplateMailer
  default from: 'payments@leohealth.com'

  def queue_name
    'payments_notifications'
  end

  def new_subscription_created(family)
    subscription = family.stripe_subscription
    subscription_amount = subscription[:plan][:amount] * subscription[:quantity]
    family.guardians.each do |user|
      delay(queue: queue_name, owner: user).mandrill_mail(
        template: 'Leo - First Invoice',
        inline_css: true,
        subject: 'Leo - Thank you for subscribing to Leo.',
        to: user.unconfirmed_email || user.email,
        vars: {
          'FIRST_NAME': user.first_name,
          'SUBSCRIPTION_AMOUNT': subscription_amount,
          'NUMBER_OF_CHILDREN': family.patients.count
        }
      )
    end
  end

  def new_payment_method(family)
    family.guardians.each do |user|
      delay(queue: queue_name, owner: user).mandrill_mail(
        template: 'Leo - New Payment Method',
        inline_css: true,
        subject: 'Leo - You have enrolled a new payment method.',
        to: user.unconfirmed_email || user.email,
        vars: {
          'FIRST_NAME': user.first_name,
        }
      )
    end
  end

  def invalid_payment_method(family)
    family.guardians.each do |user|
      delay(queue: queue_name, owner: user).mandrill_mail(
        template: 'Leo - Invalid Credit Card',
        inline_css: true,
        subject: 'Leo - Your credit card is invalid, please call us.',
        to: user.unconfirmed_email || user.email,
        vars: {
          'FIRST_NAME': user.first_name,
        }
      )
    end
  end

  def subscription_updated(family)
    subscription = family.stripe_subscription
    subscription_amount = subscription[:plan][:amount] * subscription[:quantity]
    payment_change_reason = "1 child was added to" # "Today |PAYMENT_CHANGE_REASON| your family on Leo."
    family.guardians.each do |user|
      delay(queue: queue_name, owner: user).mandrill_mail(
        template: 'Leo - Change in Plan',
        inline_css: true,
        subject: 'Leo - Your plan has changed.',
        to: user.unconfirmed_email || user.email,
        vars: {
          "FIRST_NAME": user.first_name,
          "PAYMENT_CHANGE_REASON": payment_change_reason,
          "SUBSCRIPTION_AMOUNT": subscription_amount
        }
      )
    end
  end

  def did_unsubscribe(family)
    family.guardians.each do |user|
      delay(queue: queue_name, owner: user).mandrill_mail(
        template: 'Leo - Unsubscribe Confirmation',
        inline_css: true,
        subject: 'Leo - You have been unsubscribed from Leo.',
        to: user.unconfirmed_email || user.email,
        vars: {
          'FIRST_NAME': user.first_name,
        }
      )
    end
  end
end
