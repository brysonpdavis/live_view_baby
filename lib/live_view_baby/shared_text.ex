defmodule LiveViewBaby.SharedText do
  use GenServer

  # Initialize with an empty map
  def start_link(_initial_state) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_initial_args) do
    {:ok, %{}}
  end

  # Function to get text for a specific room_id
  def get_text(room_id) do
    GenServer.call(__MODULE__, {:get_text, room_id})
  end

  def get_rooms() do
    GenServer.call(__MODULE__, {:get_rooms})
  end

  def create_room(room_id) do
    formatted_room_id = String.replace(room_id, " ", "-")

    GenServer.cast(__MODULE__, {:create_room, formatted_room_id})
  end

  # Function to set text for a specific room_id
  def set_text(room_id, new_text) do
    GenServer.cast(__MODULE__, {:set_text, room_id, new_text})
  end

  @impl true
  # Handling calls and casts
  def handle_call({:get_text, room_id}, _from, state) do
    case Map.get(state, room_id) do
      nil ->
        new_state = Map.put(state, room_id, "No submitted text, yet")
        room_ids = Map.keys(new_state)
        Phoenix.PubSub.broadcast(LiveViewBaby.PubSub, "shared_text:update", {:room_ids, room_ids})
        {:reply, "Default text", new_state}

      text -> {:reply, text, state}
    end
  end

  @impl true
  def handle_call({:get_rooms}, _from, state) do
    {:reply, Map.keys(state), state}
  end

  @impl true
  def handle_cast({:set_text, room_id, new_text}, state) do
    updated_state = Map.put(state, room_id, new_text)
    Phoenix.PubSub.broadcast(LiveViewBaby.PubSub, "shared_text:update:#{room_id}", {:shared_text, new_text})
    {:noreply, updated_state}
  end

  @impl true
  def handle_cast({:create_room, room_id}, state) do
    updated_state = Map.put(state, room_id, nil)
    Phoenix.PubSub.broadcast(LiveViewBaby.PubSub, "shared_text:update", {:room_ids, Map.keys(updated_state)})
    {:noreply, updated_state}
  end
end
