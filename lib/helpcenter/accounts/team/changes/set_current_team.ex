defmodule Helpcenter.Accounts.Team.Changes.SetCurrentTeam do
  use Ash.Resource.Change

  def change(_changeset, team, _context) do
    set_owner_current_team!(team)

    team
  end

  defp set_owner_current_team!(team) do
    dbg(team)

    Helpcenter.Accounts.User
    |> Ash.get!(team.owner_user_id)
    |> Ash.Changeset.for_update(%{current_team: team.domain})
    |> Ash.update!()
  end
end
