defmodule Chat.LoginController do
  require EEx

  EEx.function_from_file(:defp, :login_page_html,
  "lib/templates/login_page.html.eex", [])

  def perform_request(%{ path_info: ["login"], method: "GET" } = _conn) do
    login_page_html()
  end

  # def perform_request(%{path_info: ["login/success"]} = _conn) do
  #   authorize everybody forever
  # end
end
