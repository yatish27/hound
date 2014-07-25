require 'spec_helper'

describe ActivationsController, '#create' do
  context 'when activation succeeds' do
    it 'returns successful response' do
      card_token = "abc123"
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: true)
      RepoActivator.stub(new: activator)
      RepoSubscriber.stub(subscribe: true)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, card_token: card_token, format: :json

      expect(response.code).to eq '201'
      expect(response.body).to eq RepoSerializer.new(repo).to_json
      expect(activator).to have_received(:activate).
        with(repo, AuthenticationHelper::GITHUB_TOKEN)
      expect(RepoSubscriber).to have_received(:subscribe).
        with(repo, membership.user, card_token)
    end
  end

  context 'when activation fails' do
    it 'returns error response' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: false).as_null_object
      RepoActivator.stub(new: activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq '502'
      expect(activator).to have_received(:activate).
        with(repo, AuthenticationHelper::GITHUB_TOKEN)
    end

    it 'notifies Sentry' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: false).as_null_object
      RepoActivator.stub(new: activator)
      Raven.stub(:capture_exception)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(Raven).to have_received(:capture_exception).with(
        ActivationsController::FailedToActivate.new('Failed to activate repo'),
        extra: { repo_id: repo.id.to_s }
      )
    end
  end

  context 'when repo subscription fails' do
    it 'deactivates repo' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: true, deactivate: nil)
      RepoActivator.stub(new: activator)
      RepoSubscriber.stub(subscribe: false)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq '502'
      expect(activator).to have_received(:deactivate)
    end
  end
end
