defmodule MrCrowley do
  use    Application
  import Supervisor.Spec

  def pool_name() do
    :crawlers_pool
  end

  def start(_type, _args) do
    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, MrCrowley.Worker},
      {:size, 20},
      {:max_overflow, 1}
    ]

    children = [
      :poolboy.child_spec(pool_name(), poolboy_config, []),
      worker(MrCrowley.RedisRepo, [MrCrowley.RedisRepo.repo_name, "redis://localhost:6379/0"])
    ]

    options = [
      strategy: :one_for_one,
      name: MrCrowley.Supervisor
    ]

    Supervisor.start_link(children, options)
  end

  def crawl(_, nil) do
    { :ok, nil }
  end

  def crawl(site_key, url) do
    :poolboy.transaction(
      pool_name(),
      fn(pid) ->
        spawn(MrCrowley.Worker, :crawl, [pid, {site_key, url}])
      end,
      :infinity
    )
  end
end
