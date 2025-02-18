defmodule Helpcenter.Changes.Slugify do
  use Ash.Resource.Change

  @doc """
  Generate and populate a `slug` attribute while inserting a new records

  """
  def change(changeset, _opts, _context) do
    if changeset.action_type == :create do
      changeset
      |> Ash.Changeset.force_change_attribute(:slug, generate_slug(changeset))
    else
      changeset
    end
  end

  # Genarates a slug based on the name attribute. If the slug exists already,
  # Then make it unique by prefixing the `-count` at the end of the slug
  defp generate_slug(%{attributes: %{name: name}} = changeset) when not is_nil(name) do
    # 1. Generate a slug based on the namae
    slug = get_slug_from_name(name)

    # Add the count if slug exists
    case count_similar_slugs(changeset, slug) do
      {:ok, 0} -> slug
      {:ok, count} -> "#{slug}-#{count}"
      _others -> raise "Could not generate slug"
    end
  end

  #
  defp generate_slug(_changeset), do: Ash.UUIDv7

  # Generate a lowcase slug based on the string passed
  defp get_slug_from_name(name) do
    name
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
  end

  # Get a number of existing slugs
  defp count_similar_slugs(changeset, slug) do
    require Ash.Query

    changeset.resource
    |> Ash.Query.filter(slug == ^slug)
    |> Ash.count()
  end
end
