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
  end
end
