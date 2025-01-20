defmodule HelpcenterWeb.PageController do
  alias Helpcenter.KnowledgeBase.Category
  use HelpcenterWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    categories = Ash.read!(Category)
    render(conn, :home, layout: false, categories: categories)
  end
end
