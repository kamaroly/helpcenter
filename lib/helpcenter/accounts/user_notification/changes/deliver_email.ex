defmodule Helpcenter.Accounts.UserNotification.Changes.DeliverEmail do
  use Ash.Resource.Change
  import Swoosh.Email

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.change_attribute(:processed, true)
    |> Ash.Changeset.after_action(&deliver_email/2)
  end

  def atomic?(), do: false

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp deliver_email(_changeset, notification) do
    dbg(notification)

    new()
    |> from({"noreply", "noreply@example.com"})
    |> to("noreply@example.com")
    |> subject(notification.subject)
    |> text_body(notification.body)
    |> html_body(notification.body)
    |> Helpcenter.Mailer.deliver!()

    {:ok, notification}
  end
end
