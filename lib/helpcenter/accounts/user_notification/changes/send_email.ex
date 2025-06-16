defmodule Helpcenter.Accounts.UserNotification.Changes.SendEmail do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &send_email/2)
  end

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp send_email(changeset, user_notification) do
    dbg("Sending email notification...")
    dbg(changeset)
    dbg(user_notification)
    # Extract the necessary attributes from the changeset
    recipient_user_id = Ash.Changeset.get_attribute(changeset, :recipient_user_id)
    subject = Ash.Changeset.get_attribute(changeset, :subject)
    body = Ash.Changeset.get_attribute(changeset, :body)

    # # Here you would implement the logic to send the email
    # # For example, using a mailer service or library
    # # Mailer.send_email(to: recipient_user_id, subject: subject, body: body)

    Helper.Mailer.send_email(
      to: recipient_user_id,
      subject: subject,
      body: body
    )
    |> dbg()

    {:ok, user_notification}
  end
end
