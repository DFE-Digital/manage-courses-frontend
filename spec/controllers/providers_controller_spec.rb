require 'rails_helper'

RSpec.describe ProvidersController, type: :controller do
  context "with authenticated user" do
    before do
      stub_omniauth
      stub_session_create

      # TODO: This is ugly, but will be removed when controller specs are axed.
      old_controller = @controller
      @controller = SessionsController.new
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:dfe]
      get :create
      @controller = old_controller
    end

    describe 'GET #index' do
      context 'with 2 or more providers' do
        before do
          stub_api_v2_request('/providers', jsonapi(:providers_response))
        end

        it 'returns the index page' do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      context 'with 1 provider' do
        let(:the_provider) { jsonapi(:provider) }

        before do
          stub_api_v2_request('/providers', jsonapi(:providers_response, data: [the_provider]))
        end

        it 'returns the show page' do
          get :index
          expect(response).to redirect_to(action: :show, code: the_provider.attributes[:provider_code])
        end
      end

      context 'with 0 providers' do
        before do
          stub_api_v2_request('/providers', jsonapi(:providers_response, data: []))
        end

        it 'redirects to manage-courses-ui' do
          get :index
          expect(response).to redirect_to(Settings.manage_ui.base_url)
        end
      end
    end
  end
end
