defmodule Helpcenter.KnowledgeBase do
  # <-- Indicates that this file is Ash resource
  use Ash.Domain

  # `resources` is a macro A.K.A DSL to indicate that this sections lists resources under this domain
  resources do
    # `resource` is a marco indicating a resource under this domain
    resource Helpcenter.KnowledgeBase.Category
    resource Helpcenter.KnowledgeBase.Article
    resource Helpcenter.KnowledgeBase.Tag
    resource Helpcenter.KnowledgeBase.ArticleTag
    resource Helpcenter.KnowledgeBase.Comment
    resource Helpcenter.KnowledgeBase.ArticleFeedback
  end
end
