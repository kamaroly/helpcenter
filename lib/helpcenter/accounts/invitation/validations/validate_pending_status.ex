defmodule Helpcenter.Accounts.Invitation.Validations.ValidatePendingStatus do
  use Ash.Resource.Validation

  def validate(changeset, _opts, context) do
    changeset
    |> get_invitation(context)
    |> validate_invitation()
  end

  @doc """
    Atomic function's return must be the same as the main behaviour callback function.
    that's why we are not returning {:ok, validate(changeset, opts, context)}
    like in a change {:ok, change(changeset, opts, context)}
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
  defp validate_invitation({:ok, %{status: :pending}}), do: :ok

  defp validate_invitation({:ok, %{status: :accepted}}) do
    {:error, field: :token, message: "This invitation has already been accepted."}
  end

  defp validate_invitation({:ok, %{status: :declined}}) do
    {:error, field: :token, message: "This invitation has already been declined."}
  end

  defp validate_invitation(_others) do
    {:error, field: :token, message: "Invalid invitation."}
  end
end
