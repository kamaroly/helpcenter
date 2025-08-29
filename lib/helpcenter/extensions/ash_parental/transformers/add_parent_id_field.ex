# lib/helpcenter/extensions/ash_parental/transformers/add_parent_id_field.ex
defmodule Helpcenter.Extensions.AshParental.Transformers.AddParentIdField do
  use Spark.Dsl.Transformer

  def transform(dsl_state) do
    primary_key_type = get_primary_key_type(dsl_state) || :uuid

    Ash.Resource.Builder.add_new_attribute(
      dsl_state,
      :parent_id,
      primary_key_type,
      allow_nil?: false
    )
  end

  defp get_primary_key_type(dsl_state) do
    dsl_state
    |> Ash.Resource.Info.primary_key()
    |> Enum.map(&Ash.Resource.Info.attribute(dsl_state, &1))
    |> List.first()
    |> Map.get(:type)
  end
end
