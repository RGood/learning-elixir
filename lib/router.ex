defmodule Chat.Router do
  #We are using Plug.Router and creating a Plug pipeline that matches on incoming requests and routes them appropriately.
  require EEx
  use Plug.Router
  alias Chat.LoginController

  # At the top of the file we are using our Jason dependency as our JSON parser and we are using
  # Plug.Static to serve static assets like our application.js file we will make.
  plug Plug.Static,
    at: "/",
    from: :chat
  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  plug :dispatch

  EEx.function_from_file(:defp, :chat_page_html,
  "lib/templates/chat_page.html.eex", [])

  EEx.function_from_file(:defp, :application_html,
  "lib/templates/application.html.eex", [])

  get "/chat" do
    send_resp(conn, 200, chat_page_html())
  end

  get "/login" do
    req = LoginController.perform_request(conn)
    send_resp(conn, 200, req)
  end

  # match _ proceeds to match anything other than "/" .
  match _ do
    send_resp(conn, 404, "404")
  end
end
