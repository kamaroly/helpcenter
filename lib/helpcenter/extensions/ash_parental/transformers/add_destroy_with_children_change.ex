# # lib/helpcenter/extensions/ash_parental/transformers/add_delete_destroy_children_change.ex
defmodule Helpcenter.Extensions.AshParental.Transformers.AddDestroyWithChildrenChange do
  use Spark.Dsl.Transformer
  alias Helpcenter.Extensions.AshParental.Info
  alias Helpcenter.Extensions.AshParental.Changes.DestroyChildren
  alias Helpcenter.Extensions.AshParental.Transformers.AddHasManyChildrenRelationship

  @doc """
  Ensures this transformer runs after the AddHasManyChildrenRelationship transformer
  """
  def after?(AddHasManyChildrenRelationship), do: true
  def after?(_), do: false

  def transform(dsl_state) do
    if Info.ash_parental_distroy_with_children?(dsl_state) do
      # Specify only on: :destroy to avoid adding it to updates or create changes
      Ash.Resource.Builder.add_change(dsl_state, DestroyChildren, on: :destroy)
    else
      {:ok, dsl_state}
    end
  end
end
