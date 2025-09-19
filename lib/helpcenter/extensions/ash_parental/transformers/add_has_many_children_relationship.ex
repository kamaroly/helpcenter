# lib/helpcenter/extensions/ash_parental/transformers/add_has_many_children_relationship.ex
defmodule Helpcenter.Extensions.AshParental.Transformers.AddHasManyChildrenRelationship do
  use Spark.Dsl.Transformer

  def after?(Helpcenter.Extensions.AshParental.Transformers.AddParentIdAttribute), do: true
  def after?(_), do: false

  def transform(dsl_state) do
    Ash.Resource.Builder.add_new_relationship(
      dsl_state,
      :has_many,
      # <-- Use the configured children relationship name
      get_children_relationship_name(dsl_state),
      get_current_resource_name(dsl_state),
      source_attribute: get_primary_key_name(dsl_state),
      destination_attribute: :parent_id
    )
  end

  # <-- Retrieve the children relationship name from the resource configuration
  defp get_children_relationship_name(dsl_state) do
    dsl_state
    |> Helpcenter.Extensions.AshParental.Info.ash_parental_children_relationship_name!()
  end

  defp get_current_resource_name(dsl_state) do
    Spark.Dsl.Transformer.get_persisted(dsl_state, :module)
  end

  defp get_primary_key_name(dsl_state) do
    dsl_state
    |> Ash.Resource.Info.primary_key()
    |> Enum.map(&Ash.Resource.Info.attribute(dsl_state, &1))
    |> List.first()
    |> Map.get(:name)
  end
end
