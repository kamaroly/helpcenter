defmodule Helpcenter.Extensions.AshParental.Changes.DestroyChildren do
  use Ash.Resource.Change

  def change(changeset, _opts, context) do
    Ash.Changeset.before_action(changeset, &delete_children(&1, context))
  end

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp delete_children(changeset, context) do
    require Ash.Query

    %{status: :success} =
      changeset.data.__struct__
      |> Ash.Query.filter(parent_id == ^changeset.data.id)
      |> Ash.bulk_destroy(:destroy, %{}, Ash.Context.to_opts(context))

    changeset
  end
end
