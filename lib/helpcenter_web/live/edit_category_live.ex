defmodule HelpcenterWeb.EditCategoryLive do
  use HelpcenterWeb, :live_view
  alias AshPhoenix.Form

  def render(assigns) do
    ~H"""
    <.simple_form
      for={@form}
      id={"category-form-#{@category_id}"}
      phx-submit="save"
      phx-change="validate"
    >
      <h1>{gettext("New Category")}</h1>
      <.input field={@form[:name]} label={gettext("Name")} />
      <.input field={@form[:description]} label={gettext("Desription")} type="textarea" />

      <:actions>
        <.button>{gettext("Submit")}</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"category_id" => id}, _session, socket) do
    socket
    |> assign(:category_id, id)
    |> assign_form()
    |> ok()
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)

    socket
    |> assign(:form, form)
    |> noreply()
  end

  def handle_event("save", %{"form" => params}, socket) do
    case Form.submit(socket.assigns.form, params: params) do
      {:ok, category} ->
        socket
        |> put_flash(:info, "Category '#{category.name}' created!")
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> put_flash(:error, "Unable to create category")
        |> noreply()
    end
  end

  defp assign_form(socket) do
    form =
      Helpcenter.KnowledgeBase.Category
      |> Ash.get!(socket.assigns.category_id)
      |> Form.for_update(:update)
      |> to_form()

    assign(socket, :form, form)
  end
end
