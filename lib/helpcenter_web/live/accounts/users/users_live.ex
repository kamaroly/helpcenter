defmodule HelpcenterWeb.Accounts.Users.UsersLive do
  use HelpcenterWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.button phx-click={show_modal("invite-user-modal")}>
      {gettext("Invite a user")}
    </.button>
    <Cinder.Table.table query={get_query()}>
      <:col :let={row} label="Email" field="email" filter sort>{row.email}</:col>
      <:col :let={row} label="Team">{Phoenix.Naming.humanize(row.current_team)}</:col>
    </Cinder.Table.table>

    <.modal id="invite-user-modal">
     <h1>{gettext("Invite a new user to ")} {Phoenix.Naming.humanize(@current_user.current_team)} </h1>

     <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:email]} type="email" label={"New user Email"}/>
      <.input field={@form[:group_id]}  type="select" options={@access_groups} label={gettext("Select Access Group")} />
      <.button>
      {gettext("Submit")}
      </.button>
     </.simple_form>
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Users")
    |> assign_access_groups()
    |> assign_form()
    |> ok()
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    socket
    |> assign(:form, form)
    |> noreply()
  end

  @impl true
  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _invitation} ->
        socket
        |> put_flash(:info, "Invitation sent successfully")
        |> push_event("js-exec", %{to: "#invite-user-modal", attr: "data-cancel"})
        |> redirect(to: ~p"/accounts/users/invitations")
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  defp assign_access_groups(socket) do
    groups =
      Helpcenter.Accounts.Group.list_groups!(
        tenant: socket.assigns.current_user.current_team,
        authorize?: false
      )
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :access_groups, groups)
  end

  defp assign_form(socket) do
    assign(socket, :form, get_form(socket.assigns))
  end

  defp get_form(%{current_user: user}) do
    Helpcenter.Accounts.Invitation
    |> AshPhoenix.Form.for_create(:create, actor: user)
    |> to_form()
  end

  defp get_query do
    require Ash.Query

    Helpcenter.Accounts.User
    |> Ash.Query.for_read(
      :read,
      %{},
      authorize?: false
    )
  end
end
