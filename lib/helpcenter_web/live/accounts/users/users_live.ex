defmodule HelpcenterWeb.Accounts.Users.UsersLive do
  use HelpcenterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Cinder.Table.table query={get_query()}>
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

  defp get_query do
    require Ash.Query

    Helpcenter.Accounts.User
    |> Ash.Query.for_read(:read, %{}, authorize?: false)
  end
end
