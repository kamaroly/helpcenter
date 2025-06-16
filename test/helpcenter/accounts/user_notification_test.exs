defmodule Helpcenter.Accounts.UserNotificationTest do
  use HelpcenterWeb.ConnCase, async: false

  describe "User Notifications" do
    test "User notification can be send" do
      user = create_user()

      # Prepare attributes
      attrs = %{
        recipient_user_id: user.id,
        subject: "Test Notification",
        body: "This is a test notification."
      }

      dbg(attrs)

      Helpcenter.Accounts.send_email(attrs, actor: user)
      |> dbg()

      # # Create user notification
      # Helpcenter.Accounts.UserNotification
      # |> Ash.Changeset.for_create(:create, attrs, actor: user)
      # |> Ash.create()

      # assert Helpcenter.Accounts.UserNotification
      #        |> Ash.Query.filter(subject == ^attrs.subject)
      #        |> Ash.exists?(actor: user)
    end
  end
end
