defmodule Helpcenter.Extensions.AshParentalTest do
  use ExUnit.Case

  defmodule Domain do
    use Ash.Domain

    resources do
      resource Comment
    end
  end

  defmodule Comment do
    use Ash.Resource,
      domain: Domain,
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

  describe "AshParental" do
    test "AshParental adds parent_id to the resource" do
      dbg(Ash.Resource.Info.attribute_names(Comment))
    end
  end
end
