use Mix.Config

config :redis,
  url: System.get_env("REDIS_URL")

config :mr_crawley,
  url: Syste
