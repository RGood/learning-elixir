defmodule Chat.Router do
  #We are using Plug.Router and creating a Plug pipeline that matches on incoming requests and routes them appropriately.
  use Plug.Router
  require EEx

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

  EEx.function_from_file(:defp, :application_html, "lib/application.html.eex", [])

  get "/" do
    send_resp(conn, 200, application_html())
  end

  # match _ proceeds to match anything other than "/" .
  match _ do
    send_resp(conn, 404, "404")
  end
end
