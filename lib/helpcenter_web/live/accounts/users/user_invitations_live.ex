# lib/helpcenter_web/live/accounts/users/user_invitations_live.ex
defmodule HelpcenterWeb.Accounts.Users.UserInvitationsLive do
  use HelpcenterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <HelpcenterWeb.Accounts.Users.UserInvitationsLive.InviteNewUserForm.form actor={@current_user} />

    <Cinder.Table.table
      resource={Helpcenter.Accounts.Invitation}
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
    </Cinder.Table.table>
    """
  end

  @impl true
  def mount(_params, _sessions, socket) do
    socket
    |> assign(:page_title, gettext("User Invitations"))
    |> ok()
  end
end
