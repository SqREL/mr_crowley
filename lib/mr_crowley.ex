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
      {:size, 100},
      {:max_overflow, 100}
    ]

    children = [
      :poolboy.child_spec(pool_name(), poolboy_config, []),
      worker(MrCrowley.RedisRepo, [MrCrowley.RedisRepo.repo_name, Application.fetch_env!(:redis, :url)])
    ]

    options = [
      strategy: :one_for_one,
      name: MrCrowley.Supervisor
    ]

    Supervisor.start_link(children, options)
  end

  def crawl({_, :nourl}), do: nil
  def crawl({site_key, url}) do
    :poolboy.transaction(
      pool_name(),
      fn(pid) ->
        spawn(MrCrowley.Worker, :crawl, [pid, {site_key, url}])
      end,
      :infinity
    )
  end
end
