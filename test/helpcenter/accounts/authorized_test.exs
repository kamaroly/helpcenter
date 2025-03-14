# test/helpcenter/accounts/authorized_test.exs
defmodule Helpcenter.Accounts.AuthorizedTest do
  use HelpcenterWeb.ConnCase, async: false

  describe "Authorized Check" do
    test "Team owner is always authorized" do
      owner = create_user()

      assert Ash.can?({Helpcenter.KnowledgeBase.Category, :create}, owner)
      assert Ash.can?({Helpcenter.KnowledgeBase.Category, :read}, owner)
      assert Ash.can?({Helpcenter.KnowledgeBase.Category, :update}, owner)
      assert Ash.can?({Helpcenter.KnowledgeBase.Category, :destroy}, owner)
    end

    test "Nil actors are not authorized" do
      user = nil

      refute Ash.can?({Helpcenter.KnowledgeBase.Category, :create}, user)
      refute Ash.can?({Helpcenter.KnowledgeBase.Category, :read}, user)
      refute Ash.can?({Helpcenter.KnowledgeBase.Category, :update}, user)
      refute Ash.can?({Helpcenter.KnowledgeBase.Category, :destroy}, user)
    end

    test "Non team owner are allowed if they have permission" do
      owner = create_user()

      user =
        Ash.Seed.seed!(Helpcenter.Accounts.User, %{
          email: "new_user@example.com",
          current_team: owner.current_team
        })

      tenant = user.current_team

      # Add user to the team
      team = Ash.read_first!(Helpcenter.Accounts.Team)
      user_team_attrs = %{user_id: user.id, team_id: team.id}
      _user_team = Ash.Seed.seed!(Helpcenter.Accounts.UserTeam, user_team_attrs)

      # Add Access group
      group =
        Ash.Seed.seed!(
          Helpcenter.Accounts.Group,
          %{name: "Accountant", description: "Finance accountant"},
          tenant: tenant,
          authorize?: false
        )

      # Add group permission
      Ash.Seed.seed!(
        Helpcenter.Accounts.GroupPermission,
        %{group_id: group.id, action: :read, resource: Helpcenter.KnowledgeBase.Category},
        tenant: tenant,
        authorize?: false
      )

      # Add user to the group
      Ash.Seed.seed!(
        Helpcenter.Accounts.UserGroup,
        %{user_id: user.id, group_id: group.id},
        tenant: tenant,
        authorize?: false
      )

      # # Confirm that this user is not authorized to create but authorized to read
      assert Ash.can?({Helpcenter.KnowledgeBase.Category, :read}, user)
      refute Ash.can?({Helpcenter.KnowledgeBase.Category, :create}, user)
      refute Ash.can?({Helpcenter.KnowledgeBase.Category, :update}, user)
      refute Ash.can?({Helpcenter.KnowledgeBase.Category, :destroy}, user)
    end
  end
end
