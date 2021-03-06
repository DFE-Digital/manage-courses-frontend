module PageObjects
  module Page
    module Organisations
      class ConfirmAccessRequestsPage < PageObjects::Base
        set_url "/access-requests/{id}/confirm"

        element :approve, "[data-qa=\"access-request__approve\"]"
      end
    end
  end
end
