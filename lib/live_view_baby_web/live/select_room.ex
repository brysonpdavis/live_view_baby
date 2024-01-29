defmodule LiveViewBabyWeb.SelectRoom do
  use LiveViewBabyWeb, :live_view

  @impl true
  def mount(_initial, _session, socket) do
    room_ids = LiveViewBaby.SharedText.get_rooms()
    Phoenix.PubSub.subscribe(LiveViewBaby.PubSub, "shared_text:update")
    {:ok, assign(socket, room_ids: room_ids)}
  end

  @impl true
  def handle_info({:room_ids, room_ids}, socket) do
    {:noreply, assign(socket, room_ids: room_ids)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <h2 class="bold">Welcome to the place</h2>
      <%!-- create a link button for each room id --%>
      <%= for room_id <- @room_ids do %>
        <a class="btn btn-primary" href={~p"/live-test/#{room_id}"}>
          <button class="phx-click-loading:bg-red-500 ">
            <%= room_id %>
          </button>
        </a>
      <% end %>
    </div>
    """
  end
end
