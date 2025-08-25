# lib/helpcenter/accounts/invitation/changes/add_user_to_team.ex
defmodule Helpcenter.Accounts.Invitation.Changes.AddUserToTeam do
  @moduledoc """
  An Ash Resource Change that adds a user to a team and permission group.

  This module handles the process of linking a user to a team, setting their
  current team, and adding them to a permission group after accepting an invitation.
  It uses Ash's seeding and querying capabilities for reliable data operations.
  """

  use Ash.Resource.Change
  require Ash.Query

  @doc """
  Registers an after_action callback to link the user to the team after
  the changeset is processed.
  """
  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &link_user_to_team/2)
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  @doc """
  Links a user to a team and permission group based on the invitation.

  Retrieves or creates the user, associates them with the team, sets the
  current team, and adds them to the specified permission group.

  ## Parameters
    - _changeset: The Ash changeset (unused, kept for hook compatibility)
    - invitation: The invitation struct containing email, team, and group_id

  ## Returns
    - {:ok, invitation} on successful linking
    - {:error, reason} if any operation fails
  """
  def link_user_to_team(_changeset, invitation) do
    with {:ok, user} <- get_or_create_user(invitation),
         {:ok, _user_team} <- add_user_to_team(user.id, invitation.team),
         {:ok, _user_updated} <- set_user_current_team(user, invitation.team),
         {:ok, _user_group} <- add_user_to_group(user.id, invitation.group_id, invitation.team) do
      {:ok, invitation}
    else
      {:error, reason} ->
        {:error, "Failed to link user to team: #{inspect(reason)}"}
    end
  end

  defp get_team(team_name) do
    Helpcenter.Accounts.Team
    |> Ash.Query.filter(domain == ^team_name)
    |> Ash.read_first(authorize?: false)
    |> case do
      {:ok, team} -> {:ok, team}
      {:error, reason} -> {:error, reason}
    end
  end

  defp add_user_to_team(user_id, team_name) do
    with {:ok, team} <- get_team(team_name) do
      Ash.Seed.seed!(
        Helpcenter.Accounts.UserTeam,
        %{user_id: user_id, team_id: team.id},
        tenant: team_name
      )
      |> then(&{:ok, &1})
    end
  end

  defp set_user_current_team(user, team_name) do
    Ash.Seed.update!(user, %{current_team: team_name}, tenant: team_name)
    |> then(&{:ok, &1})
  end

  defp add_user_to_group(user_id, group_id, team_name) do
    Ash.Seed.seed!(
      Helpcenter.Accounts.UserGroup,
      %{user_id: user_id, group_id: group_id},
      tenant: team_name
    )
    |> then(&{:ok, &1})
  end

  defp get_or_create_user(%{email: email, team: team_name}) do
    Helpcenter.Accounts.User
    |> Ash.Query.filter(email == ^email)
    |> Ash.read_first(authorize?: false)
    |> case do
      {:ok, nil} -> create_user(email, team_name)
      {:ok, user} -> {:ok, user}
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_user(email, team_name) do
    Ash.Seed.seed!(
      Helpcenter.Accounts.User,
      %{email: email, current_team: team_name},
      tenant: team_name
    )
    |> then(&{:ok, &1})
  end
end
