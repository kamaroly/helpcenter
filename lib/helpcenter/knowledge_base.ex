defmodule Helpcenter.KnowledgeBase do
  use Ash.Domain

  resources do
    resource Helpcenter.KnowledgeBase.Category
    resource Helpcenter.KnowledgeBase.Article
    resource Helpcenter.KnowledgeBase.Tag
    resource Helpcenter.KnowledgeBase.ArticleTag
    resource Helpcenter.KnowledgeBase.Comment
    resource Helpcenter.KnowledgeBase.ArticleFeedback
  end
end
