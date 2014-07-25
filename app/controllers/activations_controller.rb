class ActivationsController < ApplicationController
  class FailedToActivate < StandardError; end

  respond_to :json

  def create
    if activator.activate(repo, session[:github_token]) && create_subscription
      render json: repo, status: :created
    else
      activator.deactivate

      report_exception(
        FailedToActivate.new('Failed to activate repo'),
        repo_id: params[:repo_id]
      )
      head 502
    end
  end

  private

  def create_subscription
    RepoSubscriber.subscribe(repo, current_user, params[:card_token])
  end

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end

  def activator
    RepoActivator.new
  end
end
