defmodule CategoryCase do
  alias Helpcenter.KnowledgeBase.Category

  def get_categories() do
    case Ash.read(Category) do
      {:ok, categories} -> categories
      _others -> create_categories()
    end
  end

  def create_categories() do
    attrs = [
      %{
        name: "Account and Login",
        slug: "account-login",
        description: "Help with account creation, login issues, and profile management"
      },
      %{
        name: "Billing and Payments",
        slug: "billing-payments",
        description: "Assistance with invoices, subscription plans, and payment issues"
      },
      %{
        name: "HR Management",
        slug: "hr-management",
        description: "Guides and support for employee onboarding, time-off, and payroll"
      },
      %{
        name: "Accounting and Finance",
        slug: "accounting-finance",
        description: "Help with financial reports, budgeting, and expense tracking"
      },
      %{
        name: "Inventory Management",
        slug: "inventory-management",
        description: "Support for stock tracking, warehouse management, and orders"
      },
      %{
        name: "Production and Manufacturing",
        slug: "production-manufacturing",
        description: "Guides for managing production schedules, resources, and outputs"
      },
      %{
        name: "Approvals and Workflows",
        slug: "approvals-workflows",
        description: "Help with configuring multi-step approvals and automated workflows"
      },
      %{
        name: "Reporting and Analytics",
        slug: "reporting-analytics",
        description: "Insights on generating and interpreting data-driven reports"
      },
      %{
        name: "System Setup and Integration",
        slug: "system-setup-integration",
        description: "Support for initial setup and integrating Zippiker with other tools"
      },
      %{
        name: "General Support",
        slug: "general-support",
        description: "Get answers to general questions and troubleshooting tips"
      }
    ]

    # We use this function to seed data into the database
    Ash.Seed.seed!(Category, attrs)
  end
end
