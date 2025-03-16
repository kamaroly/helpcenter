defmodule HelpcenterWeb.Accounts.Groups.GroupForm do
  use HelpcenterWeb, :live_component

  alias AshPhoenix.Form

  attr :id, :string, required: true
  attr :group_id, :string, default: nil
  attr :show_button, :boolean, default: true
  attr :actor, Helpcenter.Accounts.User, required: true

  def form(assigns) do
    ~H"""
    <.live_component
      id={@id}
      actor={@actor}
      module={__MODULE__}
      group_id={@group_id}
      show_button={@show_button}
    />
    """
  end

  attr :id, :string, required: true
  attr :group_id, :string, default: nil
  attr :show_button, :boolean, default: true
  attr :actor, Helpcenter.Accounts.User, required: true

  def render(assigns) do
    ~H"""
    <div id={"access-group-#{@group_id}"} class="mt-4">
      <%!-- Trigger Button --%>
      <div class="flex justify-end">
        <.button
          :if={@show_button}
          phx-click={show_modal("access-group-form-modal#{@group_id}")}
          id={"access-group-modal-button#{@group_id}"}
        >
          <.icon name="hero-plus-solid" class="h-4 w-4" /> {gettext("New")}
        </.button>
      </div>

      <.modal id={"access-group-form-modal#{@group_id}"}>
        <.simple_form
          for={@form}
          phx-change="validate"
          phx-submit="save"
          id={"access-group-form#{@group_id}"}
          phx-target={@myself}
        >
          <.input
            field={@form[:name]}
            id={"access-group-name#{@id}-#{@group_id}"}
            label={gettext("Category Name")}
          />
          <.input
            field={@form[:description]}
            id={"access-group-description#{@id}-#{@group_id}"}
            type="textarea"
            label={gettext("Description")}
          />
          <:actions>
            <.button class="w-full" phx-disable-with={gettext("Saving...")}>
              {gettext("Submit")}
            </.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_form()
    |> ok()
  end

  def handle_event("validate", %{"form" => attrs}, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, attrs))
    |> noreply()
  end

  def handle_event("save", %{"form" => attrs}, socket) do
    case Form.submit(socket.assigns.form, params: attrs) do
      {:ok, _group} ->
        socket
        |> put_component_flash(:info, gettext("Access Group Submitted."))
        |> cancel_modal("access-group-form-modal#{socket.assigns.group_id}")
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  defp assign_form(%{assigns: %{form: _form}} = socket), do: socket

  defp assign_form(%{assigns: assigns} = socket) do
    assign(socket, :form, get_form(assigns))
  end

  defp get_form(%{group_id: nil} = assigns) do
    Helpcenter.Accounts.Group
    |> Form.for_create(:create, actor: assigns.actor)
    |> to_form()
  end

  defp get_form(%{group_id: group_id} = assigns) do
    Helpcenter.Accounts.Group
    |> Ash.get!(group_id, actor: assigns.actor)
    |> Form.for_update(:update, actor: assigns.actor)
    |> to_form()
  end
end
