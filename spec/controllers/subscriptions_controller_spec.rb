require 'spec_helper'

describe SubscriptionsController, '#create' do
  context 'when subscription fails' do
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
