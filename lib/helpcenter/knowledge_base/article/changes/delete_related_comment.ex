defmodule Helpcenter.KnowledgeBase.Article.Changes.DeleteRelatedComment do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.before_action(changeset, &delete_related_comments/1)
  end

  defp delete_related_comments(changeset) do
    opts = [tenant: changeset.tenant, authorize?: false]

    %Ash.BulkResult{status: :success} =
      get_related_comments(changeset.data, opts)
      |> Ash.bulk_destroy(:destroy, _condition = %{}, opts)

    changeset
  end

  # Finds all comments related to this article
  defp get_related_comments(article, opts) do
    Helpcenter.KnowledgeBase.Comment
    |> Ash.Query.filter(article_id == ^article.id)
    |> Ash.read!(opts)
  end
end
