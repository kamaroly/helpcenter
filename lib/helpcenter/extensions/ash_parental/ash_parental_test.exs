defmodule Helpcenter.Extensions.AshParentalTest do
  use ExUnit.Case

  defmodule Comment do
    use Ash.Resource,
      domain: Helpcenter.Extensions.AshParentalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [Helpcenter.Extensions.AshParental]

    ets do
      table :comments

      private? true
    end

    attributes do
      uuid_primary_key :id
    end
  end

  defmodule Domain do
    use Ash.Domain

    resources do
      resource Helpcenter.Extensions.AshParentalTest.Comment
    end
  end

  describe "AshParental" do
    test "AshParental adds parent_id to the resource" do
      assert :parent_id in Ash.Resource.Info.attribute_names(Comment)
    end
  end
end
