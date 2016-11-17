defmodule MrCrowley.RedisRepo do
  def start_link(name, uri) do
    client = Exredis.start_using_connection_string(uri)
    true = Process.register(client, name)
    {:ok, client}
  end

  def repo_name do
    :redis
  end

  def flushall do
    repo_name |> Exredis.query(["FLUSHALL"])
  end

  def urls_for(site_key) do
    repo_name |> Exredis.query(["SMEMBERS", site_key])
  end

  def already_added?(site_key, url) do
    case repo_name |> Exredis.query(["SISMEMBER", site_key, url]) do
      "0" -> false
       _  -> true
    end
  end

  def add(site_key, url) do
    repo_name |> Exredis.query(["SADD", site_key, url])
    { site_key, url }
  end
end
