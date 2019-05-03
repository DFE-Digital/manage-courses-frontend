class ProvidersController < ApplicationController
  rescue_from JsonApiClient::Errors::NotFound, with: :not_found

  def index
    @providers = Provider.all
    render_manage_ui if @providers.empty?
    redirect_to provider_path(@providers.first.provider_code) if @providers.size == 1
  end

  def show
    @provider = Provider.find(params[:code]).first
  end
end
