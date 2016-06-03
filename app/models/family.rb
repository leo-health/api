class Family < ActiveRecord::Base
  include AASM

  has_many :guardians, -> { complete }, class_name: 'User'
  has_many :patients
  has_one :conversation
  store :stripe_customer, coder: JSON

  validates_presence_of :membership_type

  aasm whiny_transitions: false, column: :membership_type do
    state :incomplete, initial: true
    state :delinquent
    state :member
    state :exempted

    event :renew_membership do
      after do
        patients.map(&:subscribe_to_athena)
      end
      
      transitions from: [:incomplete, :delinquent], to: :member
    end

    event :expire_membership do
      transitions from: [:member, :incomplete], to: :delinquent
    end

    event :exempt_membership do
      transitions to: :exempted
    end
  end

  def members
   guardians + patients
  end

  def primary_guardian
    guardians.order('created_at ASC').first
  end

  def stripe_customer=(stripe_customer)
    limited_stripe_customer = {
      id: stripe_customer[:id]
    }

    limited_stripe_subscription = GenericHelper.try_nested_value_for_key_path(
      stripe_customer,
      [:subscriptions, :data, 0]
    ).try(:slice, :id, :quantity)

    if limited_stripe_subscription
      limited_stripe_subscription[:plan] = GenericHelper.try_nested_value_for_key_path(
        stripe_customer,
        [:subscriptions, :data, 0, :plan]
      ).try(:slice, :id, :amount)

      limited_stripe_customer[:subscriptions] = {
        data: [
          limited_stripe_subscription
        ]
      }
    end

    super limited_stripe_customer
    self.stripe_customer_id = limited_stripe_customer[:id]
  end

  def stripe_customer_id
    stripe_customer[:id] || self[:stripe_customer_id]
  end

  def stripe_subscription_id
    stripe_subscription.try(:[], :id)
  end

  def stripe_subscription
    GenericHelper.try_nested_value_for_key_path(
      stripe_customer,
      [:subscriptions, :data, 0]
    )
  end

  def update_or_create_stripe_subscription_if_needed!(credit_card_token=nil)
    patient_count = patients.count
    if !stripe_customer_id && credit_card_token
      customer_params = {
        email: primary_guardian.email,
        source: credit_card_token,
        plan: STRIPE_PLAN,
        quantity: patient_count
      }
      customer_params = customer_params.except(:plan, :quantity) if exempted?
      self.stripe_customer = Stripe::Customer.create(customer_params).to_hash
      renew_membership
    elsif credit_card_token
      customer = Stripe::Customer.retrieve stripe_customer_id
      customer.source = credit_card_token
      customer.save
      renew_membership
      PaymentsMailer.new_payment_method self
    elsif stripe_subscription_id
      subscription = Stripe::Customer.retrieve(stripe_customer_id).subscriptions.data.first
      subscription.quantity = patient_count
      subscription.save
      # immediately pay the proration amount
      Stripe::Invoice.create(customer: stripe_customer_id).pay
      self.stripe_customer = Stripe::Customer.retrieve(stripe_customer_id).to_hash
      PaymentsMailer.subscription_updated self
    end
    save!
  end
end
