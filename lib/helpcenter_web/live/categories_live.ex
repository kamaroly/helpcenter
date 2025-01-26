defmodule HelpcenterWeb.CategoriesLive do
  alias AshAuthentication.Phoenix.Components.Reset.Form
  alias Helpcenter.KnowledgeBase.Category
  use HelpcenterWeb, :live_view
  alias AshPhoenix.Form

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="category-form" phx-submit="save" phx-change="validate">
      <h1>{gettext("New Category")}</h1>
      <.input field={@form[:name]} label={gettext("Name")} />
      <.input field={@form[:description]} label={gettext("Desription")} type="textarea" />

      <:actions>
        <.button>{gettext("Submit")}</.button>
      </:actions>
    </.simple_form>

    <%!-- List table --%>
    <h1>{gettext("Categories")}</h1>

    <.table id="knowledge-base-categories" rows={@categories}>
      <:col :let={row} label={gettext("Name")}>{row.name}</:col>
      <:col :let={row} label={gettext("Description")}>{row.description}</:col>
      <:action :let={row}>
        <.button id="edit-button-{row.id}" phx-click={"edit-#{row.id}"}>{gettext("Edit")}</.button>
      </:action>
    </.table>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign_form()
    |> assign_categories()
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

  defp assign_categories(socket) do
    {:ok, categories} = Ash.read(Category)
    assign(socket, :categories, categories)
  end

  defp assign_form(socket) do
    form =
      Category
      |> Form.for_create(:create)
      |> to_form()

    assign(socket, :form, form)
  end
end
