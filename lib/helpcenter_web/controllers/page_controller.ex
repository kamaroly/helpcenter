defmodule HelpcenterWeb.PageController do
  alias Helpcenter.KnowledgeBase.Category
  use HelpcenterWeb, :controller

  def home(conn, _params) do
    # Retrieve categories with the articles
    categories = Ash.read!(Category, load: :article_count)

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false, categories: categories)
  end
end
