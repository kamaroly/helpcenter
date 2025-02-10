defmodule Helpcenter.Preparations.LimitTo5 do
  use Ash.Resource.Preparation

  def prepare(query, _opts, _context) do
    Ash.Query.limit(query, 5)
  end
end
