# lib/helpcenter_web/controllers/team_invitation_acceptance_controller.ex
defmodule HelpcenterWeb.TeamInvitationAcceptanceController do
  use HelpcenterWeb, :controller

  alias Helpcenter.Accounts.Invitation

  @doc """
  Accepts a team invitation using a tenant and token, updating the invitation status.
  Redirects to the homepage with appropriate flash messages based on the outcome.
  """
  def accept(conn, %{"tenant" => tenant, "token" => token}) do
    with {:ok, invitation} <- fetch_invitation(tenant, token),
         {:ok, _updated_invitation} <- accept_invitation(invitation, tenant) do
      conn
      |> put_flash(:info, gettext("Invitation accepted"))
      |> redirect(to: ~p"/")
    else
      {:error, error} ->
        conn
        |> put_flash(:error, format_error_message(error))
        |> redirect(to: ~p"/")
    end
  end

  def reject(conn, %{"tenant" => tenant, "token" => token}) do
    with {:ok, invitation} <- fetch_invitation(tenant, token),
         {:ok, _updated_invitation} <- reject_invitation(invitation, tenant) do
      conn
      |> put_flash(:info, gettext("Invitation rejected"))
      |> redirect(to: ~p"/")
    else
      {:error, error} ->
        conn
        |> put_flash(:error, format_error_message(error))
        |> redirect(to: ~p"/")
    end
  end

  defp fetch_invitation(tenant, token) do
    require Ash.Query

    options = [tenant: tenant, authorize?: false]

    Invitation
    |> Ash.Query.filter(token == ^token)
    |> Ash.read_first!(options)
    |> case do
      nil -> {:error, :invitation_not_found}
      invitation -> {:ok, invitation}
    end
  end

  defp accept_invitation(invitation, tenant) do
    options = [tenant: tenant, authorize?: false]

    invitation
    |> Ash.Changeset.for_update(:accept, %{}, options)
    |> Ash.update()
  end

  defp reject_invitation(invitation, tenant) do
    options = [tenant: tenant, authorize?: false]

    invitation
    |> Ash.Changeset.for_update(:accept, %{}, options)
    |> Ash.update()
  end

  defp format_error_message(:invitation_not_found) do
    gettext("Invitation not found")
  end

  defp format_error_message(%Ash.Error.Invalid{errors: errors}) do
    errors
    |> Enum.map(& &1.message)
    |> Enum.join(", ")
  end

  defp format_error_message(_other) do
    gettext("Unable to accept invitation")
  end
end
