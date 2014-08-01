class RepoSubscriber
  def self.subscribe(repo, user, card_token)
    new(repo, user, card_token).subscribe
  end

  def self.unsubscribe(repo, user)
    new(repo, user, nil).unsubscribe
  end

  def initialize(repo, user, card_token)
    @repo = repo
    @user = user
    @card_token = card_token
  end

  def subscribe
    stripe_subscription = stripe_customer.subscriptions.create(plan: repo.plan)

    puts "Was the Stripe subscription created? #{stripe_subscription}"
    puts "Creating Repo subscription..."

    # fails if repo_id already is used for a subscription
    repo.create_subscription!(
      user_id: user.id,
      stripe_subscription_id: stripe_subscription.id
    )
  rescue => error
    report_exception(error)
    stripe_subscription.try(:delete)
    nil
  end

  def unsubscribe
    stripe_subscription = stripe_customer.subscriptions.retrieve(
      repo.subscription.stripe_subscription_id
    )
    stripe_subscription.delete
    repo.subscription.destroy!
  rescue => error
    report_exception(error)
    nil
  end

  protected

  attr_reader :repo, :user, :card_token

  private

  def report_exception(error)
    Raven.capture_exception(
      error,
      extra: { user_id: user.id, repo_id: repo.id }
    )
  end

  def stripe_customer
    find_stripe_customer || create_stripe_customer
  end

  def find_stripe_customer
    customer_id = user.stripe_customer_id

    puts "Does user have a stripe_customer_id? #{customer_id}"

    if customer_id.present?
      stripe_customer = Stripe::Customer.retrieve(customer_id)

      puts "Was Stripe customer found? #{stripe_customer}"

      stripe_customer
    end
  end

  def create_stripe_customer
    stripe_customer = Stripe::Customer.create(
      email: user.email_address,
      metadata: { user_id: user.id },
      card: card_token
    )
    debugger

    user.update_attribute(:stripe_customer_id, stripe_customer.id)

    stripe_customer
  end
end
