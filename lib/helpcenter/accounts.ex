# lib/helpcenter/accounts.ex
defmodule Helpcenter.Accounts do
  use Ash.Domain, otp_app: :helpcenter

  resources do
    # Authentication
    resource Helpcenter.Accounts.Token
    resource Helpcenter.Accounts.User
    resource Helpcenter.Accounts.Team
    resource Helpcenter.Accounts.UserTeam

    # Authorization
    resource Helpcenter.Accounts.Group
    resource Helpcenter.Accounts.Permission
    resource Helpcenter.Accounts.GroupPermission

    resource Helpcenter.Accounts.UserGroup
  end
end
