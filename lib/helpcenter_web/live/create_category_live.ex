defmodule HelpcenterWeb.CreateCategoryLive do
  @moduledoc """
  Liveview module to create a new category into the database
  """

  use HelpcenterWeb, :live_view
  alias AshPhoenix.Form

  def render(assigns) do
    ~H"""
    <%!-- Display link to take user back to category list --%>
    <.back navigate={~p"/categories"}>{gettext("Back to categories")}</.back>

    <%!-- Typical simple form from core_components --%>
    <.simple_form for={@form} id="category-form" phx-submit="save" phx-change="validate">
      <h1>{gettext("New Category")}</h1>
      <.input field={@form[:name]} label={gettext("Name")} />
      <.input field={@form[:description]} label={gettext("Desription")} type="textarea" />

      <:actions>
        <.button>{gettext("Submit")}</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign_form()
    |> ok()
  end

  @doc """
  This callback does 2 main things:
  1. Validate the submitted form params against existing form
  2. Assign the validated form with its errors to the socket
  """
  def handle_event("validate", %{"form" => params}, socket) do
    # 1. Validate the form
    form = Form.validate(socket.assigns.form, params)

    socket
    |> assign(:form, form)
    |> noreply()
  end

  @doc """
  This function does 3 things:
  1. Insert submitted form params in the database if the form is valid
  2. If db insertion successed:
     2.1 It add the flash notification for the
     2.2 It redirects the user to /categories listing

  3. If insertion fails:
     3.1 It reassign the form objects with error/ reasons for failure to display
     3.2 It adds a flash notification to inform the user that it has failed.
  """
  def handle_event("save", %{"form" => params}, socket) do
    # 1. Attempt inserting into the database
    case Form.submit(socket.assigns.form, params: params) do
      {:ok, category} ->
        socket
        |> put_flash(:info, "Category '#{category.name}' created!")
        |> redirect(to: ~p"/categories")
        |> noreply()

      # 2. Recover the error in case insertion failed.
      {:error, form} ->
        socket
        |> assign(:form, form)
        |> put_flash(:error, "Unable to create category")
        |> noreply()
    end
  end

  # This private functions does 3 things
  # 1. Create a changeset for Category resource
  # 2. Inform Ash that it is for inserting new data in the data layer.
  # 3. Converts the form into liveview form so it can be handled by simple form
  defp assign_form(socket) do
    form =
      Helpcenter.KnowledgeBase.Category
      |> Form.for_create(:create)
      # Convert AshPhoenix.Form to the form understood by phoenix
      |> to_form()

    assign(socket, :form, form)
  end
end
