defmodule Helpcenter.Extensions.AshParental.Changes.DestroyChildren do
  use Ash.Resource.Change

  def change(%Ash.Changeset{action_type: :destroy} = changeset, _opts, _context) do
    dbg("DestroyChildren change called")
    Ash.Changeset.before_action(changeset, &delete_children/1)
  end

  def change(changeset, _opts, _context), do: changeset

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp delete_children(changeset) do
    require Ash.Query
    opts = Ash.Context.to_opts(changeset.context)

    Helpcenter.KnowledgeBase.Comment
    |> Ash.Query.filter(parent_id == ^changeset.data.id)
    |> Ash.read!(opts)
    |> Ash.bulk_destroy(:destroy, _condition = %{}, opts)
  end
end
