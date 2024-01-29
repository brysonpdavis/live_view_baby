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
    <div class="flex flex-row justify-between items-center">
      <a href={~p[/live-test]} class="w-fit">
        <button class="btn">
          <span class="hero-arrow-left" />Back
        </button>
      </a>
      <%!-- show the room id --%>
      <div>Room: <span class="underline"><%= @room_id %></span></div>
      </div>
      <p class="text-xl font-bold text-center"><%= @display_text %></p>
      <form class="flex flex-col gap-4" phx-submit="update_text">
        <input class="rounded" required type="text" name="new_text" placeholder="Enter new text" />
        <button class="phx-submit-loading:btn-disabled btn btn-primary" type="submit">Submit</button>
      </form>
      <button class="phx-click-loading:btn-disabled btn btn-warning" phx-click="destroy_text">
        <span class="phx-click-loading:loading phx-click-loading:loading-spinner " />
        Clear text
      </button>
    </div>
    """
  end
end
