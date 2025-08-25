defmodule HelpcenterWeb.Accounts.Users.UserInvitationsLive do
  use HelpcenterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <HelpcenterWeb.Accounts.Users.UserInvitationsLive.InviteNewUserForm.form actor={@current_user} />

    <Cinder.Table.table
      query={get_query()}
      actor={@current_user}
      id="user-invitations-table"
      page_size={20}
    >
      <:col :let={row} label="Email" field="email" filter sort>
        {Phoenix.Naming.humanize(row.email)}
      </:col>
      <:col :let={row} label="Status" field="status" filter sort>
        {Phoenix.Naming.humanize(row.status)}
      </:col>
      <:col :let={row} label="Team">{Phoenix.Naming.humanize(row.team)}</:col>
      <:col :let={row}>
        <.button phx-click={"accept-invite-#{row.token}"}>{gettext("Accept")}</.button>
      </:col>
    </Cinder.Table.table>
    """
  end

  @impl true
  def mount(_params, _sessions, socket) do
    if connected?(socket), do: HelpcenterWeb.Endpoint.subscribe("invitations")

    socket
    |> assign(:page_title, gettext("User Invitations"))
    |> ok()
  end

  @impl true
  def handle_event("accept-invite-" <> token, _params, socket) do
    %{current_user: actor} = socket.assigns
    {:ok, invitation} = Helpcenter.Accounts.Invitation.get_by_token(token, actor: actor)

    case Helpcenter.Accounts.Invitation.accept(invitation, actor: actor) do
      {:ok, _invitation} ->
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

  @impl true
  def handle_info(_event, socket) do
    socket
    |> Cinder.Table.Refresh.refresh_table("user-invitations-table")
    |> noreply()
  end

  defp get_query() do
    require Ash.Query
    Ash.Query.filter(Helpcenter.Accounts.Invitation, status == :pending)
  end
end
