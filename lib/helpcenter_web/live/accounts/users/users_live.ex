# lib/helpcenter_web/live/accounts/users/users_live.ex
defmodule HelpcenterWeb.Accounts.Users.UsersLive do
  use HelpcenterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <HelpcenterWeb.Accounts.Users.UserInvitationsLive.InviteNewUserForm.form actor={@current_user} />

    <%!-- User list --%>
    <Cinder.Table.table query={get_query(@current_user)} page_size={10} id="users-table">
      <:col :let={row} label="Email" field="email" filter sort>{row.email}</:col>
      <:col :let={row} label="Team">{Phoenix.Naming.humanize(row.current_team)}</:col>
    </Cinder.Table.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Users")
    |> ok()
  end

  defp get_query(current_user) do
    require Ash.Query

    Helpcenter.Accounts.User
    |> Ash.Query.filter(teams.domain == ^current_user.current_team)
    |> Ash.Query.for_read(:read, %{}, authorize?: false)
  end
end
