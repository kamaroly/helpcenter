# lib/helpcenter/extensions/ash_parental/ash_parental_test.exs
defmodule Helpcenter.Extensions.AshParentalTest do
  use ExUnit.Case

  # Define a simple Ash resource for testing purposes
  defmodule Comment do
    use Ash.Resource,
      domain: Helpcenter.Extensions.AshParentalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [Helpcenter.Extensions.AshParental]

    ets do
      table :comments
    end

    ash_parental do
      distroy_with_children?(true)
    end

    actions do
      defaults [:create, :read, :update, :destroy]
    end

    attributes do
      uuid_primary_key :id
      attribute :content, :string, allow_nil?: false
      timestamps()
    end
  end

  defmodule Category do
    use Ash.Resource,
      domain: Helpcenter.Extensions.AshParentalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [Helpcenter.Extensions.AshParental]

    ets do
      table :categories
    end

    ash_parental do
      children_relationship_name(:subcategories)
    end

    actions do
      defaults [:create, :read, :update, :destroy]
    end

    attributes do
      uuid_primary_key :id
      attribute :name, :string, allow_nil?: false
      timestamps()
    end
  end

  # Define a domain to hold the resource for testing
  defmodule Domain do
    use Ash.Domain

    resources do
      resource Helpcenter.Extensions.AshParentalTest.Comment
      resource Helpcenter.Extensions.AshParentalTest.Category
    end
  end

  defp relationships(resource) do
    Ash.Resource.Info.relationships(resource) |> Enum.map(& &1.name)
  end

  alias Helpcenter.Extensions.AshParentalTest.Comment

  describe "AshParental" do
    test "Adds parent_id to the resource" do
      # Confirm that the parent_id attribute has been added
      # to the reource's attributes after applying the extension
      assert :parent_id in Ash.Resource.Info.attribute_names(Comment)
    end

    test "Adds a belongs_to relationship to the resource" do
      assert :parent in relationships(Comment)
    end

    test "Adds a children relationships" do
      assert :children in relationships(Comment)
    end

    test "Adds children count aggregate" do
      %{name: aggregate_name, kind: kind} =
        Ash.Resource.Info.aggregates(Comment)
        |> List.first()

      assert :count_of_children == aggregate_name
      assert :count == kind
    end

    test "Parents - Child and versa relationships records" do
      parent = Ash.Seed.seed!(Comment, %{content: "parent"})
      child_1 = Ash.Seed.seed!(Comment, %{content: "child 1", parent_id: parent.id})
      Ash.Seed.seed!(Comment, %{content: "child 2", parent_id: parent.id})

      parent_record = Ash.get!(Comment, parent.id, load: [:children, :count_of_children])

      assert 2 == parent_record.count_of_children
      assert Enum.count(parent_record.children) == parent_record.count_of_children

      child_1_record = Ash.get!(Comment, child_1.id, load: [:parent])

      assert child_1_record.parent_id == parent.id
    end

    test "Children relationship name is configurable" do
      assert :subcategories in relationships(Category)
    end

    test "Destroying a parent also destroys its children" do
      parent = Ash.Seed.seed!(Comment, %{content: "parent"})
      Ash.Seed.seed!(Comment, %{content: "child 1", parent_id: parent.id})
      Ash.Seed.seed!(Comment, %{content: "child 2", parent_id: parent.id})

      require Ash.Query

      # assert %{status: :success} =
      Comment
      |> Ash.get!(parent.id)
      |> Ash.destroy()

      # Confirm that no children remain
      refute Comment
             |> Ash.Query.filter(parent_id == ^parent.id)
             |> Ash.exists?()
    end
  end
end
