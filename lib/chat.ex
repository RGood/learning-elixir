defmodule Chat do
  use Application

  # this is a supervised registry creation i believe
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Chat.Router,
        options: [
          dispatch: dispatch(),
          port: 4000
        ]
      ),
      Registry.child_spec(
        # We set the :keys options to :duplicate.
        # This means that multiple processes can be registered under one key in the registry.
        keys: :duplicate,
        name: Registry.Chat
      )
    ]

    opts = [strategy: :one_for_one, name: Chat.Application]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
        [
          {"/ws/[...]", Chat.SocketHandler, []},
          {:_, Plug.Cowboy.Handler, {Chat.Router, []}}
        ]
      }
    ]
  end
end
