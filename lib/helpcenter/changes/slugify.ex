defmodule Helpcenter.Changes.Slugify do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    # Only generate slug while creating
    if changeset.action_type == :create do
      Ash.Changeset.force_change_attribute(changeset, :slug, generate_slug(changeset))
    else
      changeset
    end
  end

  defp generate_slug(%{attributes: %{name: name}} = changeset) when not is_nil(name) do
    require Ash.Query

    slug =
      name
      |> String.downcase()
      |> String.replace(~r/\s+/, "-")

    # Confirm that this slug does not exists
    {:ok, count} =
      changeset.resource
      |> Ash.Query.filter(slug == ^slug)
      |> Ash.count()

    if count == 0, do: slug, else: "#{slug}-#{count}"
  end

  defp generate_slug(_changeset), do: Ash.UUIDv7
end
