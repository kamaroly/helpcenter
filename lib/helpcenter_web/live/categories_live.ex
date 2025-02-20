defmodule HelpcenterWeb.CategoriesLive do
  use HelpcenterWeb, :live_view
  on_mount {HelpcenterWeb.LiveUserAuth, :live_user_required}

  def render(assigns) do
    ~H"""
    <%!-- New Category Button --%>
    <.button id="create-category-button" phx-click={JS.navigate(~p"/categories/create")}>
      <.icon name="hero-plus-solid" />
    </.button>

    <%!-- List category records --%>
    <h1>{gettext("Categories")}</h1>

    <.table id="knowledge-base-categories" rows={@categories}>
      <:col :let={row} label={gettext("Name")}>{row.name}</:col>
      <:col :let={row} label={gettext("Description")}>{row.description}</:col>
      <:col :let={row} label={gettext("Articles")}>{row.article_count}</:col>

      <:action :let={row}>
        <%!-- Edit Category button --%>
        <.button
          id={"edit-button-#{row.id}"}
          phx-click={JS.navigate(~p"/categories/#{row.id}")}
          class="bg-white
           text-zinc-500
           hover:bg-white
           hover:text-zinc-900
           hover:underline"
        >
          <.icon name="hero-pencil-solid" />
        </.button>

        <%!-- Delete Category Button --%>
        <.button
          id={"delete-button-#{row.id}"}
          phx-click={"delete-#{row.id}"}
          class="bg-white
          text-zinc-500
          hover:bg-white
          hover:text-zinc-900"
        >
          <.icon name="hero-trash-solid" />
        </.button>
      </:action>
    </.table>
    """
  end

  def mount(_params, _session, socket) do
    # if the user is connected then subscribe to all events/ topic
    # with categories event
    if connected?(socket) do
      HelpcenterWeb.Endpoint.subscribe("categories")
    end

    socket
    |> assign_categories()
    |> ok()
  end

  # Responds when a user clicks on trash button
  def handle_event("delete-" <> category_id, _params, socket) do
    case destroy_record(category_id) do
      :ok ->
        socket
        |> put_flash(:info, "Category deleted successfully")
        |> noreply()

      {:error, _error} ->
        socket
        |> put_flash(:error, "Unable to delete category")
        |> noreply()
    end
  end

  @moduledoc """
  Function that responds when an event with topic "categories" is detected.
  It does two things
  1. It pattern matches events with topic "categories" only
  2. It refreshes categories from DB via assign_categories
  """
  def handle_info(%Phoenix.Socket.Broadcast{topic: "categories"}, socket) do
    socket
    |> assign_categories()
    |> noreply()
  end

  defp assign_categories(socket) do
    assign(socket, :categories, get_articles())
  end

  defp get_articles do
    Helpcenter.KnowledgeBase.Category
    |> Ash.Query.load(:article_count)
    |> Ash.read!()
  end

  defp destroy_record(category_id) do
    Helpcenter.KnowledgeBase.Category
    |> Ash.get!(category_id)
    |> Ash.destroy()
  end
end
