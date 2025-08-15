defmodule HelpcenterWeb.Accounts.Users.UserInvitationsLive do
  use HelpcenterWeb, :live_view

  def render(assigns) do
    ~H"""
    <Cinder.Table.table query={get_query()} actor={@current_user} id="user-invitations-table">
      <:col label="Email" :let={row} field="email" filter sort>{Phoenix.Naming.humanize(row.email)}</:col>
      <:col label="Status" :let={row} field="status" fitler sort>{Phoenix.Naming.humanize(row.status)}</:col>
      <:col label="Team" :let={row}>{Phoenix.Naming.humanize(row.team)}</:col>
      <:col :let={row}>
        <.button phx-click={"accept-invite-#{row.token}"}>{gettext("Accept")}</.button>
      </:col>
    </Cinder.Table.table>
    """
  end

  @imple true
  def mount(_params, _sessions, socket) do
    if connected?(socket) do
      HelpcenterWeb.Endpoint.subscribe("invitations")
    end

    socket
    |> assign(:page_title, gettext("User Invitations"))
    |> ok()
  end

  def handle_event("accept-invite-" <> token, _params, socket) do
    %{current_user: actor} = socket.assigns
    {:ok, invitation} = Helpcenter.Accounts.Invitation.get_by_token(token, actor: actor)

    case Helpcenter.Accounts.Invitation.accept(invitation, actor: actor) do
      {:ok, invitation} ->
        dbg(invitation)

        socket
        |> put_flash(:info, "Invitation accepted")
        |> noreply()

      {:error, error} ->
        dbg(error)

        socket
        |> put_flash(:error, "Unable to accept invitation")
        |> noreply()
    end
  end

  def handle_info(_event, socket) do
    socket
    |> Cinder.Table.refresh_table("user-invitations-table")
    |> noreply()
  end

  defp get_query() do
    require Ash.Query

    Helpcenter.Accounts.Invitation
    |> Ash.Query.filter(status == :pending)
  end
end
