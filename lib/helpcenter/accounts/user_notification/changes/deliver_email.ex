defmodule Helpcenter.Accounts.UserNotification.Changes.DeliverEmail do
  use Ash.Resource.Change
  import Swoosh.Email

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.before_action(&deliver_email/1)
    |> Ash.Changeset.change_attribute(:processed, true)
  end

  def atomic?(), do: true

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp deliver_email(%{data: notification} = changeset) do
    new()
    |> from({"noreply", "noreply@example.com"})
    |> to("noreply@example.com")
    |> subject(notification.subject || "New Notification")
    |> text_body(notification.body)
    |> html_body(notification.body)
    |> Helpcenter.Mailer.deliver!()
    |> dbg()

    {:ok, changeset}
  end
end
