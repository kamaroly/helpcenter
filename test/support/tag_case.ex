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
      %{name: "Onboarding"},
      %{name: "Payroll"},
      %{name: "Time-Off"},
      %{name: "Employee Records"},
      %{name: "Performance Reviews"},
      %{name: "Expense Tracking"},
      %{name: "Inventory Tracking"},
      %{name: "Production Planning"},
      %{name: "Multi-Step Approvals"},
      %{name: "Integrations"},
      %{name: "Reports"},
      %{name: "Data Security"},
      %{name: "Setup"},
      %{name: "Compliance"},
      %{name: "User Management"}
    ]

    Ash.Seed.seed!(Tag, attrs)
  end
end
