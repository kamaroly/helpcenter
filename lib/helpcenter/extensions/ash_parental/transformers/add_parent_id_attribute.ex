# lib/helpcenter/extensions/ash_parental/transformers/add_parent_id_attribute.ex
defmodule Helpcenter.Extensions.AshParental.Transformers.AddParentIdAttribute do
  use Spark.Dsl.Transformer

  def transform(dsl_state) do
    # Get the type of the primary key to use for the parent_id attribute
    primary_key_type = get_primary_key_type(dsl_state)

    Ash.Resource.Builder.add_new_attribute(
      dsl_state,
      :parent_id,
      primary_key_type,
      allow_nil?: false
    )
  end

  # Helper function to get the current resource primary key type
  defp get_primary_key_type(dsl_state) do
    dsl_state
    |> Ash.Resource.Info.primary_key()
    |> Enum.map(&Ash.Resource.Info.attribute(dsl_state, &1))
    |> List.first()
    |> Map.get(:type)
  end
end
