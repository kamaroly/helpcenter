defmodule HelpcenterWeb.PageController do
  alias Helpcenter.KnowledgeBase.Category
  use HelpcenterWeb, :controller

  def home(conn, _params) do
    # TODO: Configure default tenant. For now, we are picking the first available tenant

    # Retrieve categories with the articles
    categories =
      if team = Ash.read_first!(Helpcenter.Accounts.Team) do
        Ash.read!(Category, load: :article_count, tenant: team.domain)
      else
        []
      end

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false, categories: categories)
  end
end
