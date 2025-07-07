defmodule Helpcenter.Accounts.Invitation.Changes.SendWelcomeEmail do
  use Ash.Resource.Change
  use HelpcenterWeb, :verified_routes

  import Swoosh.Email
  alias Helpcenter.Mailer

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &send_invitation_email/2)
  end

  @impl true
  def atomic?, do: true

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp send_invitation_email(_changeset, invitation) do
    send(invitation.email, invitation.token)
    {:ok, invitation}
  end

  def send(email, token, _) do
    new()
    # TODO: Replace with your email
    |> from({"noreply", "noreply@example.com"})
    |> to(to_string(email))
    |> subject("Your login link")
    |> html_body(body(token: token, email: email))
    |> Mailer.deliver!()
  end

  defp body(params) do
    url = url(~p"/auth/user/magic_link/?token=#{params[:token]}")

    """
    <p>Hello, #{params[:email]}! Click this link to sign in:</p>
    <p><a href="#{url}">#{url}</a></p>
    """
  end
end
