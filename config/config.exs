# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :oauth2_server,
  ecto_repos: [Oauth2Server.Repo]

# Configures the endpoint
config :oauth2_server, Oauth2Server.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "H04AXRdk0T/QVy75Chmi6TcKnFTdtiiXUte9gsQ21N7v3HYrCGeXnDUISnsMFpAy",
  render_errors: [view: Oauth2Server.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Oauth2Server.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
