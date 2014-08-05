class SubscriptionsController < ApplicationController
  class FailedToActivate < StandardError; end

  respond_to :json

  def create
    if activator.activate(repo, github_token) && create_subscription
      render json: repo, status: :created
    else
      puts "Subscription was not created. Deactivating repo..."

      activator.deactivate(repo, github_token)

      # send more info to Sentry!!!
      report_exception(
        FailedToActivate.new('Failed to subscribe and activate repo'),
        repo_id: params[:repo_id]
      )
      head 502
    end
  end

  def destroy
    repo = current_user.repos.find(params[:repo_id])

    if activator.deactivate(repo, session[:github_token]) && delete_subscription
      render json: repo, status: :created
    else
      report_exception(
        FailedToActivate.new('Failed to unsubscribe and deactivate repo'),
        repo_id: params[:repo_id]
      )
      head 502
    end
  end

  private

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end

  def github_token
    session[:github_token]
  end

  def activator
    RepoActivator.new
  end

  def create_subscription
    RepoSubscriber.subscribe(repo, current_user, params[:card_token])
  end

  def delete_subscription
    RepoSubscriber.unsubscribe(repo, current_user)
  end
end
