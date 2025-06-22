# lib/helpcenter/accounts/user_notification/changes/deliver_email.ex
defmodule Helpcenter.Accounts.UserNotification.Changes.DeliverEmail do
  use Ash.Resource.Change
  import Swoosh.Email

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.change_attribute(:processed, true)
    |> Ash.Changeset.after_action(&deliver_email/2)
  end

  def atomic?(), do: true

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp deliver_email(_changeset, notification) do
    %{recipient_user_id: user_id} = notification

    # We need to know the recipient's email address
    # so we can send the email. At this point
    # We assume the recipient is an existing user
    recipient =
      Helpcenter.Accounts.User
      |> Ash.get!(user_id, authorize?: false)

    # Rely on Phoenix mailer infrastructure to send the email
    new()
    |> from({"noreply", "noreply@example.com"})
    |> to(to_string(recipient.email))
    |> subject(notification.subject)
    |> text_body(notification.body)
    |> html_body(notification.body)
    |> Helpcenter.Mailer.deliver!()

    {:ok, notification}
  end
end
