defmodule Helpcenter.KnowledgeBase.Category.Preparations.OrderByMostRecent do
  use Ash.Resource.Preparation

  def prepare(query, _opts, _context) do
    Ash.Query.sort(query, inserted_at: :desc)
  end
end
