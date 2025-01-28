defmodule Helpcenter.KnowledgeBase.CommentTest do
  use HelpcenterWeb.ConnCase, async: false
  alias Helpcenter.KnowledgeBase.Comment
  import CommentCase
  import ArticleCase
  require Ash.Query

  describe "Comments Tests" do
    test "A comment can be added" do
      article = get_article()
      attrs = %{content: "Article looks great!", article_id: article.id}

      Comment
      |> Ash.Changeset.for_create(:create, attrs)
      |> Ash.create()

      # Confirm that the comment has been created
      assert Comment
             |> Ash.Query.filter(content == ^attrs.content)
             |> Ash.Query.filter(article_id == ^attrs.article_id)
             |> Ash.exists?()
    end

    test "A comment can be updated" do
      comment = get_comment()

      attrs = %{content: "Updated content"}

      comment
      |> Ash.Changeset.for_update(:update, attrs)
      |> Ash.update()

      # Confirm that updates actually happened
      assert Comment
             |> Ash.Query.filter(content == ^attrs.content)
             |> Ash.Query.filter(article_id == ^comment.article_id)
             |> Ash.exists?()
    end

    test "A Comment can be deleted" do
      assert :ok = get_comment() |> Ash.destroy!()
    end

    test "Delete an article deletes its comments too without relying on data layer" do
      require Ash.Query
      comment = get_comment()

      :ok =
        Helpcenter.KnowledgeBase.Article
        |> Ash.get!(comment.article_id)
        |> Ash.destroy!()

      refute Helpcenter.KnowledgeBase.Article
             |> Ash.Query.filter(id == ^comment.id)
             |> Ash.exists?()
    end
  end
end
