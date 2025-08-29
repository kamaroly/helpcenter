defmodule Helpcenter.Extensions.AshParental.Transformers.AddChildrenCountAggregate do
  use Spark.Dsl.Transformer

  def after?(Helpcenter.Extensions.AshParental.Transformers.AddHasManyChildrenRelationship) do
    true
  end

  def after?(_), do: false

  def transform(dsl_state) do
    Ash.Resource.Builder.add_new_aggregate(
      dsl_state,
      :count_of_children,
      :count,
      [:children]
    )
  end
end
