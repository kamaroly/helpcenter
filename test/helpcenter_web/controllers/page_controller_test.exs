defmodule HelpcenterWeb.PageControllerTest do
  alias Helpcenter.KnowledgeBase.Category
  use HelpcenterWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    html = html_response(conn, 200)
    assert html =~ "Zippiker"
    assert html =~ "Advice and answers from the Zippiker Team"

    for cat <- Ash.read!(Category) do
      assert html =~ cat.name
    end
  end
end
