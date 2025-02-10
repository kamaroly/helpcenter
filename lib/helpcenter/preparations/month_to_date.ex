defmodule Helpcenter.Preparations.MonthToDate do
  use Ash.Resource.Preparation

  def prepare(query, _opts, _context) do
    # Determine the beginning of the month
    today = Date.utc_today()
    beginning_of_current_month = Date.beginning_of_month(today)
    Ash.Query.filter(query, inserted_at >= ^beginning_of_current_month)
  end
end
