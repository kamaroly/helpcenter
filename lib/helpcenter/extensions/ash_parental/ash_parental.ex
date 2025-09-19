# lib/helpcenter/extensions/ash_parental/ash_parental.ex
defmodule Helpcenter.Extensions.AshParental do
  @moduledoc """
    An Ash extension that adds parental relationships to a resource.
    When added to a resource, it will automatically add:
      - A `parent_id` attribute (of the same type as the resource's primary key)
      - A `belongs_to :parent` relationship to the same resource
      - A `has_many :children` relationship to the same resource
      - A `count_of_children` aggregate to count the number of children
  """

  @transformers [
    Helpcenter.Extensions.AshParental.Transformers.AddParentIdAttribute,

    # Add relationships after the attribute and aggregate have been added
    Helpcenter.Extensions.AshParental.Transformers.AddBelongsToParentRelationship,
    Helpcenter.Extensions.AshParental.Transformers.AddHasManyChildrenRelationship,

    # Aggregates
    Helpcenter.Extensions.AshParental.Transformers.AddChildrenCountAggregate,

    # Add the destroy children change last
    Helpcenter.Extensions.AshParental.Transformers.AddDestroyWithChildrenChange
  ]

  # Define the DSL section and its schema for configuration
  # <-- This part is added
  @section %Spark.Dsl.Section{
    name: :ash_parental,
    describe: "Configurations for the AshParental extension",
    examples: [
      """
      ash_parental do
        children_relationship_name :sub_items
        on_parent_delete_destroy_children true
      end
      """
    ],
    schema: [
      children_relationship_name: [
        type: :atom,
        doc: "The name of the children relationship to be added",
        default: :children
      ],
      distroy_with_children?: [
        type: :boolean,
        doc: "If true, deleting a parent will also delete its children",
        default: false
      ]
    ]
  }

  use Spark.Dsl.Extension,
    transformers: @transformers,
    # <-- Add the DSL section to the extension
    sections: [@section]
end
