# lib/helpcenter/accounts/invitation/validations/ensure_pending_status.ex
defmodule Helpcenter.Accounts.Invitation.Validations.EnsurePendingStatus do
  use Ash.Resource.Validation

  def validate(changeset, _opts, context) do
    changeset
    |> get_invitation(context)
    |> validate_pending_status()
  end

  @doc """
    Atomic function's return must be the same as the main behaviour callback function.
    that's why we are not returning {:ok, validate(changeset, opts, context)}
    like in a change {:ok, change(changeset, opts, context)} instead we
    retruning :ok or {:error, ...} directly as per validate definition
  """
  def atomic(changeset, opts, context) do
    validate(changeset, opts, context)
  end

  defp get_invitation(changeset, context) do
    require Ash.Query
    token = Ash.Changeset.get_attribute(changeset, :token)

    Helpcenter.Accounts.Invitation
    |> Ash.Query.filter(token == ^token)
    |> Ash.read_first(Ash.Context.to_opts(context))
  end

  # Validate that the invitation is still pending
  defp validate_pending_status({:ok, %{status: :pending}}), do: :ok

  defp validate_pending_status({:ok, %{status: :accepted}}) do
    {:error, field: :token, message: "This invitation has already been accepted."}
  end

  defp validate_pending_status({:ok, %{status: :declined}}) do
    {:error, field: :token, message: "This invitation has already been declined."}
  end

  defp validate_pending_status(_others) do
    {:error, field: :token, message: "This invitation token is invalid or has expired."}
  end
end
