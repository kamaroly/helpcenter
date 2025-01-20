defmodule CommentCase do
  alias Helpcenter.KnowledgeBase.Comment
  import ArticleCase

  def get_comment do
    case Ash.read_first(Comment) do
      {:ok, nil} -> create_comments() |> Enum.at(0)
      {:ok, comment} -> comment
    end
  end

  def get_comments do
    case Ash.read(Comment) do
      {:ok, []} -> create_comments()
      {:ok, comments} -> comments
    end
  end

  def create_comments(article \\ nil) do
    article = if is_nil(article), do: get_article(), else: article

    attrs = [
      %{
        content: "This article was really helpful for setting up my account!",
        article_id: article.id
      },
      %{
        content: "Can you elaborate more on the payroll configurations?",
        article_id: article.id
      },
      %{
        content: "I followed the inventory tracking steps, and it works perfectly!",
        article_id: article.id
      },
      %{
        content: "I encountered an issue while setting up multi-step approvals. Any tips?",
        article_id: article.id
      },
      %{
        content: "The guide on time-off policies cleared all my doubts. Thanks!",
        article_id: article.id
      },
      %{
        content: "Are there more integration examples with external tools?",
        article_id: article.id
      },
      %{
        content: "The reporting tools are great, but I’d love to see more customization options.",
        article_id: article.id
      },
      %{
        content: "I appreciate the emphasis on data security. Very reassuring.",
        article_id: article.id
      },
      %{
        content: "The troubleshooting tips in this article saved me hours of work!",
        article_id: article.id
      },
      %{
        content: "Great overview of compliance features. Extremely useful for my team.",
        article_id: article.id
      }
    ]

    Ash.Seed.seed!(Comment, attrs)
  end
end
