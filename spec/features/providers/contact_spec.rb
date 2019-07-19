require 'rails_helper'

feature 'View provider contact', type: :feature do
  let(:org_contact_page) { PageObjects::Page::Organisations::OrganisationContact.new }
  let(:provider) do
    build :provider,
          provider_code: 'A0',
          content_status: 'published'
  end

  scenario 'viewing organisation contact page' do
    allow(Settings).to receive(:rollover).and_return(false)
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{provider.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}",
      provider.to_jsonapi
    )

    visit contact_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(current_path).to eq contact_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle.year)

    expect(org_contact_page.title).to have_content('Contact details')

    expect(org_contact_page.email.value).to eq(provider.email)
    expect(org_contact_page.telephone.value).to eq(provider.telephone)
    expect(org_contact_page.website.value).to eq(provider.website)
    expect(org_contact_page.address1.value).to eq(provider.address1)
    expect(org_contact_page.address2.value).to eq(provider.address2)
    expect(org_contact_page.address3.value).to eq(provider.address3)
    expect(org_contact_page.address4.value).to eq(provider.address4)
    expect(org_contact_page.postcode.value).to eq(provider.postcode)
  end
end
