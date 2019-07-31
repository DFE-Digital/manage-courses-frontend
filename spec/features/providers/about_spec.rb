require 'rails_helper'

feature 'View provider about', type: :feature do
  let(:org_about_page) { PageObjects::Page::Organisations::OrganisationAbout.new }
  let(:provider) do
    build :provider,
          provider_code: 'A0',
          content_status: 'published'
  end

  before do
    allow(Settings).to receive(:rollover).and_return(false)
    stub_omniauth

    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}",
      provider.recruitment_cycle.to_jsonapi
    )

    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      provider.to_jsonapi
    )
  end

  scenario 'viewing organisation about page' do
    visit about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(current_path).to eq about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(org_about_page.title).to have_content('About your organisation')

    expect(org_about_page.train_with_us.value).to eq(provider.train_with_us)
    expect(org_about_page.train_with_disability.value).to eq(provider.train_with_disability)
  end

  scenario 'submitting with validation errors' do
    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      build(:error, :for_provider_update), :patch, 422
    )

    visit about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year)

    fill_in 'provider_train_with_us', with: 'foo ' * 401
    click_on 'Save'

    expect(org_about_page.error_flash).to have_content(
      'You’ll need to correct some information.'
    )
    expect(current_path).to eq about_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year)
  end
end
