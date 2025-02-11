defmodule Helpcenter.Preparations.Past do
  use Ash.Resource.Preparation

  def prepare(query, _opts, _context) do
    Ash.Query.filter(query, inserted_at < ^Date.utc_today())
  end
end
