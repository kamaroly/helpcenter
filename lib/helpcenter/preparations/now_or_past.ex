defmodule Helpcenter.Preparations.NowOrPast do
  use Ash.Resource.Preparation

  def prepare(query, _opts, _context) do
    Ash.Query.filter(query, inserted_at <= ^DateTime.utc_now())
  end
end
