defmodule LiveViewBaby.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveViewBabyWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:live_view_baby, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveViewBaby.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LiveViewBaby.Finch},
      # Start a worker by calling: LiveViewBaby.Worker.start_link(arg)
      # {LiveViewBaby.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveViewBabyWeb.Endpoint,

      # Start the shared text GenServer
      {LiveViewBaby.SharedText, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveViewBaby.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveViewBabyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
