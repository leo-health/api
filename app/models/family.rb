class Family < ActiveRecord::Base
  include AASM

  has_many :guardians, -> { complete }, class_name: 'User'
  has_many :all_guardians, class_name: 'User'
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
        complete_all_guardians!
      end

      transitions from: [:incomplete, :delinquent], to: :member
    end

    event :expire_membership do
      transitions from: [:member, :incomplete], to: :delinquent
    end

    event :exempt_membership do
      after do
        complete_all_guardians!
        if stripe_customer_id && stripe_subscription_id
          customer = Stripe::Customer.retrieve(stripe_customer_id)
          begin
            subscription = customer.subscriptions.retrieve(stripe_subscription_id)
            subscription.delete
            self.stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
          rescue Stripe::InvalidRequestError
            self.stripe_customer = customer
          end
          save!
        end
      end
      transitions to: :exempted
    end
  end

  def complete_all_guardians!
    User.incomplete.where(family: self).each { |g| g.set_complete! if g.valid_incomplete? }
  end

  def members
    guardians + patients
  end

  def primary_guardian
    User.where(family: self).order('created_at ASC').first
  end

  def stripe_customer=(stripe_customer)
    stripe_customer ||= {}
    stripe_customer = stripe_customer.to_hash
    limited_stripe_customer = parse_limited_stripe_customer(stripe_customer)
    self.stripe_customer_id = limited_stripe_customer.try(:slice, :id)
    super limited_stripe_customer
  end

  private

  def parse_limited_stripe_customer(full_stripe_customer)
    # Limit the fields we save from stripe to only what we are using at the moment. Adhere to the same json structure
    limited_stripe_customer = full_stripe_customer.try(:slice, :id)
    if limited_stripe_subscription = parse_limited_stripe_subscription(full_stripe_customer)
      limited_stripe_subscription[:plan] = parse_limited_stripe_subscription_plan(full_stripe_customer)
      limited_stripe_customer[:subscriptions] = {
        data: [
          limited_stripe_subscription
        ]
      }
    end
    limited_stripe_customer
  end

  def parse_limited_stripe_subscription(full_stripe_customer)
    GenericHelper.try_nested_value_for_key_path(
      full_stripe_customer,
      [:subscriptions, :data, 0]
    ).try(:slice, :id, :quantity)
  end

  def parse_limited_stripe_subscription_plan(full_stripe_customer)
    GenericHelper.try_nested_value_for_key_path(
      full_stripe_customer,
      [:subscriptions, :data, 0, :plan]
    ).try(:slice, :id, :amount)
  end

  public

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
    return unless primary_guardian
    if !stripe_customer_id && credit_card_token
      create_stripe_customer(credit_card_token)
    elsif credit_card_token
      update_stripe_customer_payment_method(credit_card_token)
    elsif stripe_subscription_id
      update_subscription_quantity
    end
    save!
    stripe_customer
  end

  private

  def create_stripe_customer(credit_card_token)
    customer_params = {
      email: primary_guardian.email,
      source: credit_card_token,
      plan: STRIPE_PLAN,
      quantity: patients.count
    }
    customer_params = customer_params.except(:plan, :quantity) if exempted?

    begin
      self.stripe_customer = Stripe::Customer.create(customer_params).to_hash
      PaymentsMailer.new_subscription_created(self) unless exempted?
    rescue Stripe::CardError => e
      expire_membership!
      raise e
    end
    renew_membership
  end

  def update_stripe_customer_payment_method(credit_card_token)
    customer = Stripe::Customer.retrieve stripe_customer_id
    customer.source = credit_card_token
    customer.save
    renew_membership
    PaymentsMailer.new_payment_method self
  end

  def update_subscription_quantity
    subscription = Stripe::Customer.retrieve(stripe_customer_id).subscriptions.data.first
    return unless subscription
    subscription.quantity = patients.count
    subscription.save
    self.delay(
      queue: "invoice_payment",
      owner: self,
      run_at: Time.now
    ).pay_invoice
    self.stripe_customer = Stripe::Customer.retrieve(stripe_customer_id).to_hash
    PaymentsMailer.subscription_updated self
  end

  def pay_invoice
    Stripe::Invoice.create(customer: stripe_customer_id).pay
  end
end
