require "rails_helper"

feature "Get courses as an accredited body", type: :feature do
  let(:organisation_training_providers_page) { PageObjects::Page::Organisations::TrainingProviders.new }
  let(:courses_as_an_accredited_body_page) { PageObjects::Page::Organisations::OrganisationCoursesAsAnAccreditedBody.new }

  let(:course1) { build :course, has_vacancies?: true }
  let(:accrediting_body1) { build :provider, accredited_body?: true, courses: [course1] }

  let(:course2) { build :course }
  let(:accrediting_body2) { build :provider, accredited_body?: true, courses: [course2] }

  let(:training_provider2) { build :provider, accredited_bodies: [accrediting_body1, accrediting_body2], courses: [course1, course2] }

  let(:user) { build :user, :admin }
  let(:access_request) { build :access_request }

  before do
    course1.accrediting_provider = accrediting_body1
    stub_omniauth(user: user)
    stub_api_v2_resource(accrediting_body1)
    stub_api_v2_resource(accrediting_body2)
    stub_api_v2_resource(training_provider2)
    stub_api_v2_resource(accrediting_body1.recruitment_cycle)
    stub_api_v2_request(
      "/recruitment_cycles/#{training_provider2.recruitment_cycle.year}/providers/" \
      "#{training_provider2.provider_code}?include=courses.accrediting_provider",
      training_provider2.to_jsonapi(include: :courses),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{accrediting_body1.recruitment_cycle.year}/providers/" \
      "#{accrediting_body1.provider_code}/courses?filter%5Baccrediting_provider%5D=#{accrediting_body1.provider_code}",
      resource_list_to_jsonapi([course1]),
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{accrediting_body1.recruitment_cycle.year}/providers/" \
      "#{accrediting_body1.provider_code}/training_providers?recruitment_cycle_year=#{accrediting_body1.recruitment_cycle.year}",
      resource_list_to_jsonapi([training_provider2, accrediting_body2]),
    )
    stub_api_v2_resource_collection([access_request])
  end

  context "When the training provider has courses" do
    context "as an admin user" do
      it "can be reached from the provider show page" do
        visit training_providers_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year)
        organisation_training_providers_page.training_providers.first.link.click
        expect(current_path).to eq training_provider_courses_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year, training_provider2.provider_code)
      end

      it "should have the correct content" do
        name_and_course_code = "#{course1.name} (#{course1.course_code})"
        visit training_provider_courses_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year, training_provider2.provider_code)

        expect(courses_as_an_accredited_body_page).to have_content("Training provider")
        expect(courses_as_an_accredited_body_page).to have_content(training_provider2.provider_name)
        expect(courses_as_an_accredited_body_page.courses_tables.first.rows.first.course_name.text).to eq("#{name_and_course_code} PGCE with QTS full time")
        expect(courses_as_an_accredited_body_page).not_to have_link(name_and_course_code)
        expect(courses_as_an_accredited_body_page.courses_tables.first.rows.first.find_link["href"]).to eq("#{Settings.search_ui.base_url}/course/#{training_provider2.provider_code}/#{course1.course_code}")
        expect(courses_as_an_accredited_body_page.courses_tables.first.rows.first.vacancies.text).to eq("Yes")
      end

      it "doesn't show courses accredited by different accredited bodies" do
        course_accreredited_by_a_different_body = "#{course2.name} (#{course2.course_code})"
        visit training_provider_courses_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year, training_provider2.provider_code)

        expect(courses_as_an_accredited_body_page).not_to have_content(course_accreredited_by_a_different_body)
      end

      it "should have the correct breadcrumbs" do
        visit training_provider_courses_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year, training_provider2.provider_code)

        within(".govuk-breadcrumbs") do
          expect(page).to have_link(accrediting_body1.provider_name.to_s, href: "/organisations/#{accrediting_body1.provider_code}")
          expect(page).to have_link("Courses as an accredited body", href: "/organisations/#{accrediting_body1.provider_code}/#{accrediting_body1.recruitment_cycle.year}/training-providers")
          expect(page).to have_content("#{training_provider2.provider_name}’s courses")
        end
      end
    end

    context "as a non-admin user" do
      let(:user) { build(:user) }

      it "redirects to to the organisation show page" do
        visit training_providers_provider_recruitment_cycle_path(accrediting_body1.provider_code, accrediting_body1.recruitment_cycle.year)

        expect(current_path).to eq provider_path(accrediting_body1.provider_code)
      end
    end
  end
end
