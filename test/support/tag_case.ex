defmodule TagCase do
  alias Helpcenter.KnowledgeBase.Tag

  def get_tags do
    case(Ash.read(Tag)) do
      {:ok, records} -> records
      _others -> create_tags()
    end
  end

  def create_tags do
    attrs = [
      %{
        name: "Onboarding",
        slug: "onboarding"
      },
      %{
        name: "Payroll",
        slug: "payroll"
      },
      %{
        name: "Time-Off",
        slug: "time-off"
      },
      %{
        name: "Employee Records",
        slug: "employee-records"
      },
      %{
        name: "Performance Reviews",
        slug: "performance-reviews"
      },
      %{
        name: "Expense Tracking",
        slug: "expense-tracking"
      },
      %{
        name: "Inventory Tracking",
        slug: "inventory-tracking"
      },
      %{
        name: "Production Planning",
        slug: "production-planning"
      },
      %{
        name: "Multi-Step Approvals",
        slug: "multi-step-approvals"
      },
      %{
        name: "Integrations",
        slug: "integrations"
      },
      %{
        name: "Reports",
        slug: "reports"
      },
      %{
        name: "Data Security",
        slug: "data-security"
      },
      %{
        name: "Setup",
        slug: "setup"
      },
      %{
        name: "Compliance",
        slug: "compliance"
      },
      %{
        name: "User Management",
        slug: "user-management"
      }
    ]

    Ash.Seed.seed!(Tag, attrs)
  end
end
