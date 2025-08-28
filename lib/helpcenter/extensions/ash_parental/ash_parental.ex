defmodule Helpcenter.Extensions.AshParental do
  use Spark.Dsl.Extension,
    transformers: [Helpcenter.Extensions.AshParental.Transformers.AddParentIdField]
end
