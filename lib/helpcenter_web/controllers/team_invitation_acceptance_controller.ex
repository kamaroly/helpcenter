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

      {:error, error} ->
        dbg(error)
        put_flash(conn, :error, gettext("Unable to accept invitation"))
    end
  end
end
