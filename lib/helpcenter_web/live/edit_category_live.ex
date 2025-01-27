defmodule HelpcenterWeb.EditCategoryLive do
  @moduledoc """
  Edits an existing categroy
  """
  use HelpcenterWeb, :live_view

  def render(assigns) do
    ~H"""
    <%!-- Display link to take user back to category list --%>
    <.back navigate={~p"/categories"}>{gettext("Back to categories")}</.back>

    <HelpcenterWeb.Categories.CategoryForm.form category_id={@category_id} />
    """
  end

  def mount(%{"category_id" => category_id} = _params, _session, socket) do
    socket
    |> assign(:category_id, category_id)
    |> ok()
  end
end
