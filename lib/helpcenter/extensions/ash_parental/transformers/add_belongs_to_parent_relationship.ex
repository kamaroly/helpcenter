defmodule Helpcenter.Extensions.AshParental.Transformers.AddBelongsToParentRelationship do
  use Spark.Dsl.Transformer

  @doc """
  Ensure that this transformer runs after the AddParentIdField transformer. This will prevent
  errors where the relationship is added before the parent_id field exists.
  """
  def after?(Helpcenter.Extensions.AshParental.Transformers.AddParentIdField), do: true
  def after?(_), do: false

  def transform(dsl_state) do
    Ash.Resource.Builder.add_new_relationship(
      dsl_state,
      :belongs_to,
      :parent,
      get_current_resource_name(dsl_state),
      source_attribute: :parent_id,
      destination_attribute: get_primary_key_name(dsl_state)
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
