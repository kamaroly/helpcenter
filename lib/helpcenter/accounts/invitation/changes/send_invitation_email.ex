defmodule Helpcenter.Accounts.Invitation.Changes.SendInvitationEmail do
  use Ash.Resource.Change
  use HelpcenterWeb, :verified_routes

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &send_invitation_email/2)
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp send_invitation_email(_changeset, invitation) do
    %{email: email, token: token, team: team} = invitation
    message = body(token: token, email: email, tenant: team)

    %{
      id: token,
      params: %{
        html_message: message,
        text_message: message,
        subject: "You are invited",
        from: nil,
        to: email
      }
    }
    |> Helpcenter.Workers.EmailSender.new()
    |> Oban.insert()

    {:ok, invitation}
  end

  defp body(params) do
    url = url(~p"/accounts/users/invitations/#{params[:tenant]}/#{params[:token]}/accept")

    """
    <p>Hello, #{params[:email]}! Click this link to accept the invitation to #{params[:tenant]}.</p>
    <p><a href="#{url}">#{url}</a></p>
    """
  end
end
