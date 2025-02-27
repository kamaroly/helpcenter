defmodule Helpcenter.KnowledgeBase.Article.Changes.DeleteRelatedComment do
  @moduledoc """
  Change to delete all comments belonging to the article before deleting
  the article itself.
  """
  use Ash.Resource.Change

  def change(%Ash.Changeset{action_type: :destroy} = changeset, _opts, _context) do
    Ash.Changeset.before_action(changeset, &delete_related_comments/1)
  end

  def change(changeset, _opts, _context), do: changeset
  def atomic(changeset, _opts, _context), do: {:ok, changeset}

  defp delete_related_comments(changeset) do
    opts = [tenant: changeset.tenant, authorize?: false]

    %Ash.BulkResult{status: :success} =
      get_related_comments(changeset.data, opts)
      |> delete_comments(opts)

    changeset
  end

  # Finds all comments related to this article
  defp get_related_comments(article, opts) do
    Helpcenter.KnowledgeBase.Comment
    |> Ash.Query.filter(article_id == ^article.id)
    |> Ash.read!(opts)
  end

  defp delete_comments([], _opts), do: %Ash.BulkResult{status: :success}

  defp delete_comments(records, opts) do
    Ash.bulk_destroy(records, :destroy, _condition = %{}, opts)
  end
end
