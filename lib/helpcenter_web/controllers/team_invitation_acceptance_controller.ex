defmodule HelpcenterWeb.TeamInvitationAcceptanceController do
  use HelpcenterWeb, :controller

  def accept(conn, %{"tenant" => tenant, "token" => token}) do
    require Ash.Query

    options = [tenant: tenant, authorize?: false]

    Helpcenter.Accounts.Invitation
    |> Ash.Query.filter(token == ^token)
    |> Ash.read_first!(options)
    |> Ash.Changeset.for_update(:accept, %{}, options)
    |> Ash.update()
    |> case do
      {:ok, _inv} ->
        conn
        |> put_flash(:info, gettext("Invitation accepted"))
        |> redirect(to: ~p"/")

      {:error, %Ash.Error.Invalid{errors: errors}} ->
        error_message =
          Enum.map(errors, & &1.message)
          |> Enum.join(", ")

        conn
        |> put_flash(:error, error_message)
        |> redirect(to: ~p"/")

      {:error, _other} ->
        conn
        |> put_flash(:error, gettext("Unable to accept invitation"))
        |> redirect(to: ~p"/")
    end
  end
end
