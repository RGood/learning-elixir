defmodule Chat.SocketHandler do
  # First note, we are referencing the :cowboy_websocket module with @behaviour.
  # This makes sure we implement the necessary callbacks that are defined by :cowboy_websocket.
  # Those are init/2, websocket_init/1, websocket_handle/2, and websocket_info/2.
  @behaviour :cowboy_websocket
  # inside of init/2 we are going to grab the path from the request
  # and save that to the state variable that gets passed along to the
  # websocket_init/1 function. It is inside this function that we will
  # utilize Elixir’s Registry module.

  # If you want to see what the process’s pid is when your code runs
  # you can add IO.inspect(self()) to the top of the websocket_init/1
  # function and it will print to your terminal.
  def init(request, _state) do
    state = %{registry_key: request.path}

    {:cowboy_websocket, request, state}
  end

  # Anytime someone opens their browser and travels to the page of our website
  # which makes a web socket request with that path name ("/ws/chat")
  #a process id number for their web socket connection will be saved in Registry.Chat

  def websocket_init(state) do
    Registry.Chat
    |> Registry.register(state.registry_key, {})

    {:ok, state}
  end

  # When the browser client actually sends a message utilizing the web socket connection
  # the websocket_handle/2 callback is triggered. This callback has a return value of
  # {:reply, {:text, message}, state}.
  # This actually sends a message back to the client that sent the original web socket
  # message. In our case we want to broadcast that message to every process in the
  # Registry.Chat that shares the same key (users who have made a request to "/ws/chat"
  # by navigating to our home page). This means we use the dispatch/2 function to iterate
  # over all of the pids that are registered and send them the desired message with Process.send/3.
  def websocket_handle({:text, json}, state) do
    payload = Jason.decode!(json)
    message = payload["data"]["message"]

    Registry.Chat
    |> Registry.dispatch(state.registry_key, fn(entries) ->
      for {pid, _} <- entries do
        if pid != self() do
          Process.send(pid, message, [])
        end
      end
    end)

    {:reply, {:text, message}, state}
  end

  #This is where the special websocket_info/2 callback is utilized.
  # Whenever an Elixir process sends a message to our Chat.SocketHandler
  # the callback is triggered. This callback has a return value just
  # like websocket_handle/2 which returns a message to the original client.

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end
end
