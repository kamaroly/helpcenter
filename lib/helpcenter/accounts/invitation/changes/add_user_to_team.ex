defmodule Helpcenter.Accounts.Invitation.Changes.AddUserToTeam do
  use Ash.Resource.Change
  require Ash.Query

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &link_user_team/2)
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp link_user_team(_changeset, invite) do
    tenant = invite.team
    # 1. get user
    user = get_or_create_user(invite)

    # 2. Link user to the team
    _user_team = add_user_to_team(user.id, tenant)
    _user_current_team = set_user_current_team(user, tenant)

    # 3. Add user to the permission group
    _user_group = add_user_to_group(user.id, invite.group_id, tenant)
    {:ok, invite}
  end

  defp get_team(team) do
    Helpcenter.Accounts.Team
    |> Ash.Query.filter(domain == ^team)
    |> Ash.read_first!(authorize?: false)
  end

  defp add_user_to_team(user_id, tenant) do
    team = get_team(tenant)

    Ash.Seed.seed!(
      Helpcenter.Accounts.UserTeam,
      %{user_id: user_id, team_id: team.id},
      tenant: tenant
    )
  end

  defp set_user_current_team(user, tenant) do
    Ash.Seed.update!(user, %{current_team: tenant}, tenant: tenant)
  end

  defp add_user_to_group(user_id, group_id, tenant) do
    Ash.Seed.seed!(
      Helpcenter.Accounts.UserGroup,
      %{user_id: user_id, group_id: group_id},
      tenant: tenant
    )
  end

  defp get_or_create_user(%{email: email} = invitation) do
    Helpcenter.Accounts.User
    |> Ash.Query.filter(email == ^email)
    |> Ash.read_first(authorize?: false)
    |> case do
      {:ok, nil} -> create_user(email, invitation.team)
      {:ok, user} -> user
    end
  end

  defp create_user(email, tenant) do
    Ash.Seed.seed!(Helpcenter.Accounts.User, %{email: email}, tenant: tenant)
  end
end
