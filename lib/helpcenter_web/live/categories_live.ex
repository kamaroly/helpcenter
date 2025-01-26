defmodule HelpcenterWeb.CategoriesLive do
  alias Helpcenter.KnowledgeBase.Category
  use HelpcenterWeb, :live_view

  def render(assigns) do
    ~H"""
    <.button id="create-category-button" phx-click={JS.navigate(~p"/categories/create")}>
      <.icon name="hero-plus-solid" />
    </.button>

    <%!-- List table --%>
    <h1>{gettext("Categories")}</h1>

    <.table id="knowledge-base-categories" rows={@categories}>
      <:col :let={row} label={gettext("Name")}>{row.name}</:col>
      <:col :let={row} label={gettext("Description")}>{row.description}</:col>
      <:action :let={row}>
        <.button
          id={"edit-button-#{row.id}"}
          phx-click={JS.navigate(~p"/categories/#{row.id}")}
          class="bg-transparent  text-zinc-500 hover:bg-transparent hover:text-zinc-900 hover:underline"
        >
          <.icon name="hero-pencil-solid" />
        </.button>

        <.button class="bg-transparent  text-zinc-500 hover:bg-transparent hover:text-zinc-900">
          <.icon name="hero-trash-solid" />
        </.button>
      </:action>
    </.table>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign_categories()
    |> ok()
  end

  defp assign_categories(socket) do
    {:ok, categories} = Ash.read(Category)
    assign(socket, :categories, categories)
  end
end
