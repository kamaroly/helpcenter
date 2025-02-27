defmodule HelpcenterWeb.Categories.CategoryForm do
  use HelpcenterWeb, :live_component
  alias AshPhoenix.Form

  @doc """
  This funciton allows us to call this component as if it was a static component

  ### Example:
      - <HelpcenterWeb.Categories.CategoryForm.form /> for creating a new category
      - <HelpcenterWeb.Categories.CategoryForm.form category_id={...}/> for editing an existing category

  ### Params
    id: unique string identifer for this components. It allows us to have this component multiple times on the same page.
        default: UUIDv7
    category_id: unique category identifier needed while editing this component
  """
  attr :id, :string, default: Ash.UUIDv7.generate()
  attr :category_id, :string, default: nil
  attr :actor, :map, required: true

  def form(assigns) do
    ~H"""
    <.live_component id={@id} module={__MODULE__} category_id={@category_id} actor={@actor} />
    """
  end

  attr :id, :string, default: Ash.UUIDv7.generate()
  attr :category_id, :string, default: nil
  attr :actor, :map, required: true

  def render(assigns) do
    ~H"""
    <div id={"category-form-component-#{@id}"}>
      <%!--
       This form must target its self so that phx-change and phx-submit events stays in it.
       Otherwise these changes will be sent to the parent liveview
      --%>
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

  # This callback does 2 main things:
  # 1. Validate the submitted form params against existing form
  # 2. Assign the validated form with its errors to the socket

  def handle_event("validate", %{"form" => params}, socket) do
    # 1. Validate the form
    form = Form.validate(socket.assigns.form, params)

    socket
    |> assign(:form, form)
    |> noreply()
  end

  #
  # This function does 3 things:
  # 1. Insert submitted form params in the database if the form is valid
  # 2. If db insertion successed:
  #    2.1 It add the flash notification for the
  #    2.2 It redirects the user to /categories listing

  # 3. If insertion fails:
  #    3.1 It reassign the form objects with error/ reasons for failure to display
  #    3.2 It adds a flash notification to inform the user that it has failed.
  #
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

  # Assign form to this component assigns
  defp assign_form(socket) do
    assign(socket, :form, get_form(socket.assigns))
  end

  # New category form
  # 1. Create a changeset for Category resource
  # 2. Inform Ash that it is for inserting new data in the data layer.
  # 3. Converts the form into liveview form so it can be handled by simple form

  # Prevent overriding existing form during update on changes
  defp get_form(%{form: _form} = assigns), do: assigns

  # Form for creating a new category
  defp get_form(%{category_id: nil, actor: actor}) do
    Helpcenter.KnowledgeBase.Category
    |> Form.for_create(:create, actor: actor)
    |> to_form()
  end

  # Form for existing category
  defp get_form(%{category_id: category_id, actor: actor}) do
    Helpcenter.KnowledgeBase.Category
    |> Ash.get!(category_id)
    |> Form.for_update(:update, actor: actor)
    |> to_form()
  end
end
