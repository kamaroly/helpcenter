defmodule Helpcenter.Accounts.Invitation.Changes.AddUserToTeam do
  alias Helpcenter.Accounts.Invitation
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &add_user_to_team/2)
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp add_user_to_team(_changeset, invite) do
    # 1. get user
    user = get_or_create_user(invite)
    # 2. add user to the team
    # 3. Add user to the permission group

    {:ok, invite}
  end

  defp get_or_create_user(%Invitation{} = invitation) do
    dbg(invitation)
  end
end
