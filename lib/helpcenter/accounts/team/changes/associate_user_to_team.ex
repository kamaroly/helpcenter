defmodule Helpcenter.Accounts.Team.Changes.AssociateUserToTeam do
  @moduledoc """
  Link user to the team via user_teams relationship so that when
  we are listing owners teams, this team will be listed as well
  """

  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &associate_owner_to_team/2)
  end

  defp associate_owner_to_team(_changeset, team) do
    params = %{user_id: team.owner_user_id, team_id: team.id}

    {:ok, _user_team} =
      Helpcenter.Accounts.UserTeam
      |> Ash.Changeset.for_create(:create, params)
      |> Ash.create()

    {:ok, team}
  end
end
