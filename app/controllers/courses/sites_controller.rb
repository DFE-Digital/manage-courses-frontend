module Courses
  class SitesController < ApplicationController
    decorates_assigned :course
    include CourseBasicDetailConcern

    before_action :build_course
    before_action :build_provider_with_sites

    def edit; end

    def update
      @course.provider_code = @provider.provider_code
      selected_site_ids = params.dig(:course, :site_statuses_attributes)
        .values
        .select { |f| f["selected"] == "1" }
        .map { |f| f["id"] }

      @course.sites = @provider.sites.select { |site| selected_site_ids.include?(site.id) }

      if @course.save
        success_message = @course.is_running? ? "Course locations saved and published" : "Course locations saved"
        redirect_to provider_recruitment_cycle_course_path(params[:provider_code], params[:recruitment_cycle_year], params[:code]), flash: { success: success_message }
      else
        @errors = @course.errors.full_messages

        render :edit
      end
    end

  private

    def build_provider_with_sites
      @provider = Provider
                    .includes(:sites)
                    .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                    .find(params[:provider_code])
                    .first
    end

    def build_course
      @provider_code = params[:provider_code]
      @course = Course
        .includes(:sites)
        .includes(provider: [:sites])
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: @provider_code)
        .find(params[:code])
        .first
    end
  end
end
