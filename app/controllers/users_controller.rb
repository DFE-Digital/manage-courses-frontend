class UsersController < ApplicationController
  def accept_transition_info
    User.member(current_user['user_id']).accept_transition_screen
    redirect_to providers_path
  rescue JsonApiClient::Errors::ClientError, JsonApiClient::Errors::ServerError => e
    e.env.body.delete("traces")
    Raven.extra_context(e.env)
    Raven.capture_exception(e)

    if e.is_a? JsonApiClient::Errors::ClientError
      redirect_to providers_path
    else
      raise e
    end
  end
end
