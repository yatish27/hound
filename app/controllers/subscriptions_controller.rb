class SubscriptionsController < ApplicationController
  def create
    stripe_subscription = stripe_customer.subscriptions.create(plan: repo.plan)

    repo.create_subscription(
      user_id: current_user.id,
      stripe_subscription_id: stripe_subscription.id
    )

    head 201
  end

  private

  def stripe_customer
    find_stripe_customer || create_stripe_customer
  end

  def find_stripe_customer
    customer_id = current_user.stripe_customer_id

    if customer_id.present?
      Stripe::Customer.retrieve(customer_id)
    end
  end

  def create_stripe_customer
    stripe_customer = Stripe::Customer.create(
      email: current_user.email_address,
      metadata: {
        user_id: current_user.id
      },
      card: params[:card_token]
    )

    current_user.update_attribute(:stripe_customer_id, stripe_customer.id)

    stripe_customer
  end

  def repo
    current_user.repos.find(params[:repo_id])
  end
end
