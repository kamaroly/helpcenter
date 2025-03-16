defmodule HelpcenterWeb.Accounts.Groups.GroupsLive do
  use HelpcenterWeb, :live_view

  def render(assigns) do
    ~H"""
    <%!-- Access Group Create form --%>
    <HelpcenterWeb.Accounts.Groups.GroupForm.form actor={@current_user} id={Ash.UUIDv7.generate()} />

    <%!-- Table groups --%>
    <.table
      id="groups"
      rows={@groups}
      row_click={fn row -> JS.navigate(~p"/accounts/groups/#{row.id}") end}
    >
      <:col :let={group} label="id">{group.name}</:col>
      <:col :let={group} label="username">{group.description}</:col>
    </.table>
    """
  end

  def mount(_params, _sessions, socket) do
    socket
    |> subscribe_to_pubsub()
    |> assign_groups()
    |> ok()
  end

  def handle_info(_message, socket) do
    socket
    |> assign_groups()
    |> noreply()
  end

  defp subscribe_to_pubsub(socket) do
    if connected?(socket) do
      HelpcenterWeb.Endpoint.subscribe("groups")
    end

    socket
  end

  defp assign_groups(socket) do
    assign(socket, :groups, get_groups(socket.assigns.current_user))
  end

  defp get_groups(actor) do
    Ash.read!(Helpcenter.Accounts.Group, actor: actor)
  end
end
