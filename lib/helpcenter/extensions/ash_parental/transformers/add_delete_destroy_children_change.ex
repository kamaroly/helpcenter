# # lib/helpcenter/extensions/ash_parental/transformers/add_delete_destroy_children_change.ex
defmodule Helpcenter.Extensions.AshParental.Transformers.AddDeleteDestroyChildrenChange do
  use Spark.Dsl.Transformer

  def after?(Helpcenter.Extensions.AshParental.Transformers.AddHasManyChildrenRelationship),
    do: true

  def after?(_), do: false

  def transform(dsl_state) do
    if Helpcenter.Extensions.AshParental.Info.ash_parental_on_parent_delete_destroy_children?(
         dsl_state
       ) do
      Ash.Resource.Builder.add_change(
        dsl_state,
        Helpcenter.Extensions.AshParental.Changes.DestroyChildren
      )
    else
      dsl_state
    end
  end
end

# # lib/helpcenter/extensions/ash_parental/transformers/add_delete_destroy_children_change.ex
