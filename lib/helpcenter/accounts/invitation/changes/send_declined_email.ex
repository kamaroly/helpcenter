# lib/helpcenter/accounts/invitation/changes/send_declined_email.ex
defmodule Helpcenter.Accounts.Invitation.Changes.SendDeclinedEmail do
  @moduledoc """
  An Ash Resource Change that sends a declination email after an invitation is declined.

  This module handles the process of sending an email notification to the user
  who declined a team invitation. It integrates with Oban for async email delivery.
  """

  use Ash.Resource.Change
  use HelpcenterWeb, :verified_routes

  @doc """
  Implements the change hook for Ash, registering an after_action callback
  to send the declination email.
  """
  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &send_email/2)
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp send_email(_changeset, invitation) do
    with {:ok, email_data} <- build_email_data(invitation),
         {:ok, _job} <- schedule_email(email_data) do
      {:ok, invitation}
    else
      {:error, reason} ->
        {:error, "Failed to send declination email: #{inspect(reason)}"}
    end
  end

  defp build_email_data(%{email: email, token: token, team: team}) do
    message = build_email_body(team)

    email_data = %{
      id: token,
      params: %{
        html_message: message,
        text_message: message,
        subject: "You declined an invitation to join #{team}",
        from: nil,
        to: email
      }
    }

    {:ok, email_data}
  end

  defp build_email_body(team) do
    """
    <p>Hello,</p>
    <p>You have declined the invitation to join the <strong>#{team}</strong> team.</p>
    <p>If this was a mistake, please contact the team administrator.</p>
    """
  end

  defp schedule_email(email_data) do
    email_data
    |> Helpcenter.Workers.EmailSender.new()
    |> Oban.insert()
  end
end
