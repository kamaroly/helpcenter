# lib/helpcenter_web/live/accounts/users/user_invitations_live/invite_new_user_form.ex
defmodule HelpcenterWeb.Accounts.Users.UserInvitationsLive.InviteNewUserForm do
  @moduledoc """
  LiveComponent that renders a form to invite a new user to the current user's team.
  The form includes fields for the user's email and the access group they should be assigned to.
  When the form is submitted, an invitation is created in the system, and an invitation email
  is sent to the provided email address.

  This component is designed to be used within a modal dialog, which can be triggered by a button
  elsewhere in the application. The modal button is this compoent
  """
  use HelpcenterWeb, :live_component

  @doc """
  This a wrapper used to access this component like a static component
  in the template.
  """
  attr :actor, Helpcenter.Accounts.User, required: true

  def form(assigns) do
    ~H"""
    <.live_component id={Ash.UUIDv7.generate()} actor={@actor} module={__MODULE__} />
    """
  end

  attr :id, :string, default: Ash.UUIDv7.generate()
  attr :actor, Helpcenter.Accounts.User, required: true

  def render(assigns) do
    ~H"""
    <div id={"access-group-#{@id}"} class="mt-4">
      <.button phx-click={show_modal("invite-user-modal")} id="invite-user-modal-button">
        {gettext("Invite a user")}
      </.button>
      <.modal id="invite-user-modal">
        <div class="flex flex-col space-y-1.5 text-center sm:text-left">
          <h3 class="text-xl font-semibold leading-none tracking-tight">
            {gettext("Invite a new member to your team")}
          </h3>
          <p class="text-sm text-gray-500">
            {gettext(
              "Invite a new user to your team by entering their email address below. They will receive an invitation email with instructions on how to join your team."
            )}
          </p>
        </div>

        <.simple_form for={@form} phx-change="validate" phx-submit="save" phx-target={@myself}>
          <.input field={@form[:email]} type="email" label="New user Email" />
          <.input
            field={@form[:group_id]}
            type="select"
            options={@access_groups}
            label={gettext("Select Access Group")}
          />
          <div class="w-full justify-end flex">
            <.button>
              {gettext("Invite User")} <.icon name="hero-paper-airplane-solid" class="ml-2 h-5 w-5" />
            </.button>
          </div>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
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

  defp assign_form(socket) do
    assign(socket, :form, get_form(socket.assigns))
  end

  # Prevents the form from being re-created on every update
  defp get_form(%{form: form}) when is_map(form), do: form

  defp get_form(%{actor: actor}) do
    Helpcenter.Accounts.Invitation
    |> AshPhoenix.Form.for_create(:create, actor: actor)
    |> to_form()
  end

  defp assign_access_groups(socket) do
    %{actor: actor} = socket.assigns

    groups =
      Helpcenter.Accounts.Group
      |> Ash.read!(tenant: actor.current_team, authorize?: false)
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :access_groups, groups)
  end
end
