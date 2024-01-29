defmodule LiveViewBabyWeb.LiveTest do
  use LiveViewBabyWeb, :live_view

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    text = LiveViewBaby.SharedText.get_text(room_id)
    Phoenix.PubSub.subscribe(LiveViewBaby.PubSub, "shared_text:update:#{room_id}")
    {:ok, assign(socket, display_text: text, room_id: room_id)}
  end

  @impl true
  def handle_event("update_text", %{"new_text" => new_text}, socket) do
    room_id = socket.assigns.room_id
    LiveViewBaby.SharedText.set_text(room_id, new_text)
    {:noreply, assign(socket, display_text: new_text)}
  end

  @impl true
  def handle_event("destroy_text", _params, socket) do
    room_id = socket.assigns.room_id
    LiveViewBaby.SharedText.set_text(room_id, nil)

    {:noreply, assign(socket, display_text: nil)}
  end

  @impl true
  def handle_info({:shared_text, new_text}, socket) do
    {:noreply, assign(socket, display_text: new_text)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 capitalize">
      <p><%= @display_text %></p>
      <form class="flex flex-col gap-4" phx-submit="update_text">
        <input class="rounded" type="text" name="new_text" placeholder="Enter new text" />
        <button class="phx-submit-loading:bg-green-400" type="submit">Submit</button>
      </form>
      <button class="phx-click-loading:bg-red-500" phx-click="destroy_text">
        Clear text
      </button>
    </div>
    """
  end
end
