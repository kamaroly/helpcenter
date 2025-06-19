defmodule Helpcenter.Accounts.UserNotificationTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  describe "User Notifications" do
    test "User notification can be send" do
      user = create_user()

      attrs = %{
        recipient_user_id: user.id,
        subject: "Test Notification",
        body: "This is a test notification body text."
      }

      {:ok, _notification} = Helpcenter.Accounts.notify(attrs, actor: user)

      # Confirm we have the notification in the database
      assert Helpcenter.Accounts.UserNotification
             |> Ash.Query.filter(recipient_user_id == ^user.id)
             |> Ash.Query.filter(subject == ^attrs.subject)
             |> Ash.Query.filter(body == ^attrs.body)
             |> Ash.Query.filter(processed == false)
             |> Ash.exists?(actor: user)

      # Confirm the job can be queued and triggered in the background
      assert %{success: 2} =
               AshOban.Test.schedule_and_run_triggers(
                 Helpcenter.Accounts.UserNotification,
                 actor: user
               )

      # Confirm the notification was processed and marked as such
      assert Helpcenter.Accounts.UserNotification
             |> Ash.Query.filter(recipient_user_id == ^user.id)
             |> Ash.Query.filter(subject == ^attrs.subject)
             |> Ash.Query.filter(body == ^attrs.body)
             |> Ash.Query.filter(processed == true)
             |> Ash.exists?(actor: user)
    end
  end
end
