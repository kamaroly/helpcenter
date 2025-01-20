defmodule Helpcenter.KnowledgeBase.TagTest do
  use HelpcenterWeb.ConnCase, async: false
  alias Helpcenter.KnowledgeBase.Tag
  require Ash.Query
  import TagCase

  describe "Knowledge Base Tags Tests" do
    test "User can create a new tag" do
      attrs = %{name: "Billing", slug: "billing"}

      Tag
      |> Ash.Changeset.for_create(:create, attrs)
      |> Ash.create()

      assert Tag
             |> Ash.Query.filter(name == ^attrs.name)
             |> Ash.Query.filter(slug == ^attrs.slug)
             |> Ash.exists?()
    end

    test "User can filter existings tags" do
      create_tags()

      assert Tag
             |> Ash.Query.filter(name == "Time-Off")
             |> Ash.exists?()
    end

    test "User can update an existing tag" do
      create_tags()

      {:ok, tag} =
        Tag
        |> Ash.Query.filter(name == "Time-Off")
        |> Ash.read_first!()
        |> Ash.Changeset.for_update(:update, %{name: "Leave", slug: "leave"})
        |> Ash.update()

      assert Tag
             |> Ash.Query.filter(name == ^tag.name)
             |> Ash.Query.filter(slug == ^tag.slug)
             |> Ash.read_first()
    end

    test "User can delete an existing tag" do
      create_tags()

      assert :ok =
               Tag
               |> Ash.Query.filter(name == "Time-Off")
               |> Ash.read_first!()
               |> Ash.destroy!()
    end
  end
end
