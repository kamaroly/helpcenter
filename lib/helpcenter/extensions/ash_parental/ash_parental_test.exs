# lib/helpcenter/extensions/ash_parental/ash_parental_test.exs
defmodule Helpcenter.Extensions.AshParentalTest do
  use ExUnit.Case

  defmodule Comment do
    use Ash.Resource,
      domain: Helpcenter.Extensions.AshParentalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [Helpcenter.Extensions.AshParental]

    ets do
      table :comments
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

  defmodule Domain do
    use Ash.Domain

    resources do
      resource Helpcenter.Extensions.AshParentalTest.Comment
    end
  end

  defp relationships(resource) do
    Ash.Resource.Info.relationships(resource)
    |> Enum.map(& &1.name)
  end

  alias Helpcenter.Extensions.AshParentalTest.Comment

  describe "AshParental" do
    test "Adds parent_id to the resource" do
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
      child_2 = Ash.Seed.seed!(Comment, %{content: "child 2", parent_id: parent.id})

      parent_record = Ash.get!(Comment, parent.id, load: [:children, :count_of_children])

      assert 2 == parent_record.count_of_children
      assert Enum.count(parent_record.children) == parent_record.count_of_children

      child_1_record = Ash.get!(Comment, child_1.id, load: [:parent])

      assert child_1_record.parent_id == parent.id
    end
  end
end
