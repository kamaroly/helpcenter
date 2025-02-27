defmodule Helpcenter.KnowledgeBase.TagTest do
  use HelpcenterWeb.ConnCase, async: false
  alias Helpcenter.KnowledgeBase.Tag
  require Ash.Query
  import TagCase

  describe "Knowledge Base Tags Tests" do
    test "User can create a new tag" do
      user = create_user()
      attrs = %{name: "Billing #{Ash.UUIDv7.generate()}"}

      {:ok, tag} =
        Tag
        |> Ash.Changeset.for_create(:create, attrs, actor: user)
        |> Ash.create()

      assert user.current_team == Ash.Resource.get_metadata(tag, :tenant)
    end

    test "User can filter existings tags" do
      user = create_user()
      create_tags(user.current_team)

      assert Tag
             |> Ash.Query.filter(name == "Time-Off")
             |> Ash.exists?(actor: user)
    end

    test "User can update an existing tag" do
      user = create_user()
      create_tags(user.current_team)

      {:ok, tag} =
        Tag
        |> Ash.Query.filter(name == "Time-Off")
        |> Ash.read_first!(actor: user)
        |> Ash.Changeset.for_update(:update, %{name: "Leave"})
        |> Ash.update(actor: user)

      assert Tag
             |> Ash.Query.filter(name == ^tag.name)
             |> Ash.read_first(actor: user)
    end

    test "User can delete an existing tag" do
      user = create_user()
      create_tags(user.current_team)

      assert :ok =
               Tag
               |> Ash.Query.filter(name == "Time-Off")
               |> Ash.read_first!(actor: user)
               |> Ash.destroy!(actor: user)
    end
  end
end
