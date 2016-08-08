use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :oauth2_server, Oauth2Server.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []


# Watch static and templates for browser reloading.
config :oauth2_server, Oauth2Server.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  level: :debug,
  format: "[$level]$time $metadata $message\n",
  metadata: [:module, :line, :function]

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :oauth2_server, Oauth2Server.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "dynamite",
  database: "cpp",
  hostname: "localhost",
  pool_size: 10

config :oauth2_server, AuthConfig,
  site: "https://localhost:4000"

config :exredis,
  host: "localhost",
  port: 6379,
  password: "",
  db: 0,
  reconnect: :no_reconnect,
  max_queue: :infinity

config :oauth2_server, Oauth2Server.Settings, 
  access_token_expiration: 3600,
  refresh_token_expiration: 3600
