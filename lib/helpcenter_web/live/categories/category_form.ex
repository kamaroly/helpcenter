defmodule HelpcenterWeb.Categories.CategoryForm do
  use HelpcenterWeb, :live_component
  alias AshPhoenix.Form

  attr :id, :string, default: Ash.UUIDv7.generate()
  attr :category_id, :string, default: nil

  def form(assigns) do
    ~H"""
    <.live_component id={@id} module={__MODULE__} category_id={@category_id} />
    """
  end

  attr :id, :string, default: Ash.UUIDv7.generate()
  attr :category_id, :string, default: nil

  def render(assigns) do
    ~H"""
    <div id={"category-form-component-#{@id}"}>
      <%!-- Typical simple form from core_components --%>
      <.simple_form
        for={@form}
        id={"category-form-#{@category_id}"}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <h1>{gettext("New Category")}</h1>
        <.input field={@form[:name]} label={gettext("Name")} />
        <.input field={@form[:description]} label={gettext("Desription")} type="textarea" />

        <:actions>
          <.button>{gettext("Submit")}</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
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

  defp assign_form(socket) do
    form = get_form(socket.assigns)
    assign(socket, :form, form)
  end

  # New category form
  # 1. Create a changeset for Category resource
  # 2. Inform Ash that it is for inserting new data in the data layer.
  # 3. Converts the form into liveview form so it can be handled by simple form
  defp get_form(%{category_id: nil}) do
    Helpcenter.KnowledgeBase.Category
    |> Form.for_create(:create)
    |> to_form()
  end

  # Ecisting form
  defp get_form(%{category_id: category_id}) do
    Helpcenter.KnowledgeBase.Category
    |> Ash.get!(category_id)
    |> Form.for_update(:update)
    |> to_form()
  end
end
