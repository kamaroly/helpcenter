defmodule Helpcenter.Extensions.AshParental do
  defmodule Comment do
    use Ash.Resource, extensions: [Helpcenter.Extensions.AshParental]
  end

  describe "AshParental" do
    test "AshParental adds parent_id to the resource" do
      dbg(Ash.Resource.Info.attribute_names(Comment))
    end
  end
end
