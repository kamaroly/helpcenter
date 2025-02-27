defmodule HelpcenterWeb.PageControllerTest do
  use HelpcenterWeb.ConnCase
  import CategoryCase

  test "GET /", %{conn: conn} do
    user = create_user()
    categories = create_categories(user.current_team)

    conn = get(conn, ~p"/")
    html = html_response(conn, 200)
    assert html =~ "Zippiker"
    assert html =~ "Advice and answers from the Zippiker Team"

    for category <- categories do
      assert html =~ category.name
      assert html =~ category.description
    end
  end
end
