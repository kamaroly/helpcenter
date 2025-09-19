# Ash Parental Resource
Ash Parental is an extension that brings STI(Single Table Inheritance) capability to a resource

## What is single table inheritance (STI)?

It's a fancy name for a simple concept: Extending a resource (usually to add specific behavior), but referencing the same table.

```ex
defmodule MyApp.Comment do
    use Ash.Resource, extensions: [AshParental]
    ....
end
```

The above should do the following:
1.Add `parent_id` attributes that is nullable
2.Add `parent` belongs to relationship
3.Add `children` has_many relationship
4.Add `children_count` aggregates

Configurations 

```ex

ash_parental do
    children_relationship_name :subcategories 
    
end
```
