defmodule ArticleCase do
  alias Helpcenter.KnowledgeBase.Article
  import CategoryCase

  def get_article do
    case Ash.read_first(Article) do
      {:ok, nil} -> create_articles() |> Enum.at(0)
      {:ok, article} -> article
    end
  end

  def get_articles do
    case Ash.read(Article) do
      {:ok, []} -> create_articles()
      {:ok, articles} -> articles
    end
  end

  def create_articles(category \\ nil) do
    category = if is_nil(category), do: get_category(), else: category

    attrs = [
      %{
        title: "Getting Started with Zippiker",
        slug: "getting-started-zippiker",
        content: "Learn how to set up your Zippiker account and configure basic settings.",
        views_count: 1452,
        published: true,
        category_id: category.id
      },
      %{
        title: "How to Manage Payroll Efficiently",
        slug: "manage-payroll-efficiently",
        content: "Step-by-step guide to setting up payroll processes in Zippiker.",
        views_count: 928,
        published: true,
        category_id: category.id
      },
      %{
        title: "Best Practices for Inventory Tracking",
        slug: "best-practices-inventory-tracking",
        content: "Tips and tricks to optimize inventory management using Zippiker.",
        views_count: 721,
        published: true,
        category_id: category.id
      },
      %{
        title: "Configuring Multi-Step Approvals",
        slug: "configuring-multi-step-approvals",
        content: "Learn how to set up and manage multi-step approvals for key processes.",
        views_count: 569,
        published: false,
        category_id: category.id
      },
      %{
        title: "Understanding Time-Off Policies",
        slug: "understanding-time-off-policies",
        content:
          "A comprehensive guide to creating and managing time-off policies for employees.",
        views_count: 1033,
        published: true,
        category_id: category.id
      },
      %{
        title: "Integrating Zippiker with Third-Party Tools",
        slug: "integrating-zippiker-tools",
        content:
          "Discover how to connect Zippiker to external applications for seamless operations.",
        views_count: 456,
        published: false,
        category_id: category.id
      },
      %{
        title: "The Role of Reports in Decision Making",
        slug: "role-reports-decision-making",
        content: "Explore how Zippiker's reporting tools can drive better business decisions.",
        views_count: 849,
        published: true,
        category_id: category.id
      },
      %{
        title: "Enhancing Data Security in Zippiker",
        slug: "enhancing-data-security",
        content:
          "Learn about Zippiker's data protection features and how to use them effectively.",
        views_count: 684,
        published: true,
        category_id: category.id
      },
      %{
        title: "Common Issues During Setup and How to Fix Them",
        slug: "setup-common-issues",
        content: "Troubleshooting guide for common challenges faced during initial setup.",
        category_id: category.id
      },
      %{
        title: "Compliance Features in Zippiker",
        slug: "compliance-features-zippiker",
        content: "Overview of compliance management features built into Zippiker.",
        views_count: 599,
        published: true,
        category_id: category.id
      }
    ]

    Ash.Seed.seed!(Helpcenter.KnowledgeBase.Article, attrs)
  end
end
