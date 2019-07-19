class ProvidersController < ApplicationController
  decorates_assigned :provider
  rescue_from JsonApiClient::Errors::NotFound, with: :not_found
  before_action :build_provider, except: %i[index show]

  def index
    @providers = Provider
      .where(year: Settings.current_cycle)
      .all

    render_manage_ui if @providers.empty?
    redirect_to provider_path(@providers.first.provider_code) if @providers.size == 1
  end

  def show
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle
    )

    @provider = Provider
      .where(year: cycle_year)
      .find(params[:code])
      .first
  end

  def contact; end

  def details; end

private

  def build_provider
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle
    )

    @provider = Provider
      .where(year: cycle_year)
      .find(params[:provider_code])
      .first
  end
end
