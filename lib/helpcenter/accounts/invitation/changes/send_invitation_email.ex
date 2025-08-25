# lib/helpcenter/accounts/invitation/changes/send_invitation_email.ex
defmodule Helpcenter.Accounts.Invitation.Changes.SendInvitationEmail do
  @moduledoc """
  An Ash Resource Change that sends an invitation email to a user.

  This module handles sending an email to invite a user to join a team,
  including a link to accept the invitation. It uses Oban for asynchronous
  email delivery.
  """

  use Ash.Resource.Change
  use HelpcenterWeb, :verified_routes

  @doc """
  Registers an after_action callback to send the invitation email after
  the changeset is processed.
  """
  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &send_email/2)
  end

  @doc """
  Implements the atomic change hook for Ash to ensure atomic operations.
  """
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
        {:error, "Failed to send invitation email: #{inspect(reason)}"}
    end
  end

  defp build_email_data(%{email: email, token: token, team: team}) do
    message = build_email_body(email, token, team)

    email_data = %{
      id: token,
      params: %{
        html_message: message,
        text_message: message,
        subject: "You're Invited to Join #{team}",
        from: nil,
        to: email
      }
    }

    {:ok, email_data}
  end

  defp build_email_body(email, token, team) do
    accept_url = url(~p"/accounts/users/invitations/#{team}/#{token}/accept")

    """
    <p>Hello, #{email}!</p>
    <p>You've been invited to join the <strong>#{team}</strong> team.</p>
    <p>Please click the link below to accept the invitation:</p>
    <p><a href="#{accept_url}">Accept Invitation</a></p>
    <p>If you believe this invitation was sent in error, please contact the team administrator.</p>
    """
  end

  defp schedule_email(email_data) do
    email_data
    |> Helpcenter.Workers.EmailSender.new()
    |> Oban.insert()
  end
end
