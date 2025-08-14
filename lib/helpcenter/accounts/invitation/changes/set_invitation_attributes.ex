defmodule Helpcenter.Accounts.Invitation.Changes.SetInvitationAttributes do
  use Ash.Resource.Change

  @alphabet String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_", "",
              trim: true
            )
  @alphabet_length length(@alphabet)

  @impl true
  def change(changeset, _opts, context) do
    Ash.Changeset.before_transaction(changeset, &set_attributes(&1, context))
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp set_attributes(changeset, context) do
    expires_at = DateTime.add(DateTime.utc_now(), 30, :day)

    changeset
    |> Ash.Changeset.force_change_attribute(:token, generate())
    |> Ash.Changeset.force_change_attribute(:expires_at, expires_at)
    |> Ash.Changeset.force_change_attribute(:team, changeset.tenant)
    |> Ash.Changeset.force_change_attribute(:inviter_user_id, context.actor.id)
    |> Ash.Changeset.force_change_attribute(:team, context.actor.current_team)
  end

  @doc """
  Generates a YouTube-like ID by randomly selecting characters from a custom alphabet.
  """
  def generate(length \\ 11) do
    Stream.repeatedly(fn -> Enum.at(@alphabet, :rand.uniform(@alphabet_length) - 1) end)
    |> Enum.take(length)
    |> Enum.join()
  end
end
