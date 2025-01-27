defmodule HelpcenterWeb.EditCategoryLive do
  @moduledoc """
  Edits an existing categroy
  """
  use HelpcenterWeb, :live_view
  alias AshPhoenix.Form

  def render(assigns) do
    ~H"""
    <%!-- Display link to take user back to category list --%>
    <.back navigate={~p"/categories"}>{gettext("Back to categories")}</.back>

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

  @doc """
  1. Retrieves category_id from the route parameter
  2. Assign it in the socket
  3. Assign form in the socket
  """
  def mount(%{"category_id" => id} = _params, _session, socket) do
    socket
    |> assign(:category_id, id)
    |> assign_form()
    |> ok()
  end

  @doc """
  Validates and assign validated form to the socket
  """
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)

    socket
    |> assign(:form, form)
    |> noreply()
  end

  @doc """
  Attempts category update or show erros explaining why it failed
  """
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

  @doc """
  1. Gets category by id
  2. Generates its AshPhoenix.Form for update action
  3. Converts it into the phoenix form
  4. Assign it to the socket
  """
  defp assign_form(socket) do
    form =
      Helpcenter.KnowledgeBase.Category
      |> Ash.get!(socket.assigns.category_id)
      |> Form.for_update(:update)
      |> to_form()

    assign(socket, :form, form)
  end
end
