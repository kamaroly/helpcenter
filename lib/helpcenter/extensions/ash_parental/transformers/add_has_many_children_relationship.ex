defmodule Helpcenter.Extensions.AshParental.Transformers.AddHasManyChildrenRelationship do
  use Spark.Dsl.Transformer

  def after?(Helpcenter.Extensions.AshParental.Transformers.AddParentIdField), do: true
  def after?(_), do: false

  def transform(dsl_state) do
    Ash.Resource.Builder.add_new_relationship(
      dsl_state,
      :has_many,
      :children,
      get_current_resource_name(dsl_state),
      source_attribute: get_primary_key_name(dsl_state),
      destination_attribute: :parent_id
    )
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
