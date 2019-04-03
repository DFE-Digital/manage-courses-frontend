require 'rails_helper'

RSpec.feature 'Sign in', type: :feature do
  skip 'using DfE Sign-in' do
    stub_omniauth(disable_completely: false)
    stub_session_create
    stub_api_v2_request('/providers', jsonapi(:providers_response))

    visit root_path

    # Redirect to DfE Signin and come back
    expect(page).to have_content("Sign out (John Smith)")
  end
end
