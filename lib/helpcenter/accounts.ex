# lib/helpcenter/accounts.ex
defmodule Helpcenter.Accounts do
  use Ash.Domain, otp_app: :helpcenter

  resources do
    resource Helpcenter.Accounts.Team
    resource Helpcenter.Accounts.User
    resource Helpcenter.Accounts.Group
    resource Helpcenter.Accounts.UserTeam
    resource Helpcenter.Accounts.UserGroup
    resource Helpcenter.Accounts.GroupPermission

    resource Helpcenter.Accounts.Token
    resource Helpcenter.Accounts.Invitation

    resource Helpcenter.Accounts.UserNotification do
      define :notify, action: :create
    end
  end
end
