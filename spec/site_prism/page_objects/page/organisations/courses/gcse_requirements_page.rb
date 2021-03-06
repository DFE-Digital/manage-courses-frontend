module PageObjects
  module Page
    module Organisations
      module Courses
        class GcseRequirementsPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/gcses-pending-or-equivalency-tests{?query*}"

          element :pending_gcse_yes_radio, '[data-qa="gcse_requirements__pending_gcse_yes_radio"]'
          element :pending_gcse_no_radio, '[data-qa="gcse_requirements__pending_gcse_no_radio"]'

          element :gcse_equivalency_yes_radio, '[data-qa="gcse_requirements__gcse_equivalency_yes_radio"]'
          element :english_equivalency, '[data-qa="gcse_requirements__english_equivalency"]'
          element :maths_equivalency, '[data-qa="gcse_requirements__maths_equivalency"]'
          element :science_equivalency, '[data-qa="gcse_requirements__science_equivalency"]'
          element :additional_requirements, '[data-qa="gcse_requirements__additional_requirements"]'
          element :gcse_equivalency_no_radio, '[data-qa="gcse_requirements__gcse_equivalency_no_radio"]'

          element :save, '[data-qa="gcse_requirements__save"]'
        end
      end
    end
  end
end
