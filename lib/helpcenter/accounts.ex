# lib/helpcenter/accounts.ex
defmodule Helpcenter.Accounts do
  use Ash.Domain, otp_app: :helpcenter

  resources do
    resource Helpcenter.Accounts.Token
    resource Helpcenter.Accounts.User
    resource Helpcenter.Accounts.Team
    resource Helpcenter.Accounts.UserTeam
    resource Helpcenter.Accounts.Permission
  end
end
