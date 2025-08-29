# lib/helpcenter/extensions/ash_parental/ash_parental.ex
defmodule Helpcenter.Extensions.AshParental do
  @transformers [
    Helpcenter.Extensions.AshParental.Transformers.AddParentIdField,
    Helpcenter.Extensions.AshParental.Transformers.AddChildrenCountAggregate,
    Helpcenter.Extensions.AshParental.Transformers.AddBelongsToParentRelationship,
    Helpcenter.Extensions.AshParental.Transformers.AddHasManyChildrenRelationship
  ]

  use Spark.Dsl.Extension, transformers: @transformers
end
