defmodule Helpcenter.Accounts.Invitation.Preparations.ForCurrentTeam do
  use Ash.Resource.Preparation

  def prepare(query, _options, %{actor: nil}), do: query

  def prepare(query, _opts, context) do
    %{current_team: team} = context.actor
    Ash.Query.filter(query, team == ^team)
  end
end
