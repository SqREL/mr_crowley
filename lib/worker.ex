defmodule MrCrowley.Worker do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({site_key, url}, from, state) do
    { _, urls } = {site_key, url}
    |> MrCrowley.UrlNormalizer.normalize
    |> push_url
    |> get_urls
    
    Enum.map(urls, fn(url) ->
      MrCrowley.crawl(site_key, url)
    end)

    {:reply, "Done", state}
  end

  def push_url({site_key, nil}), do: {site_key, nil}
  def push_url({site_key, url}) do
    MrCrowley.RedisRepo.add(site_key, url)
    {site_key, url}
  end


  def get_urls({site_key, nil}), do: { site_key, []}
  def get_urls({site_key, url}, retries_count \\ 0) do
    %{body: body} = HTTPotion.get(url, follow_redirects: true)
    MrCrowley.Parser.parse({site_key, body})
  rescue
    HTTPotion.ErrorResponse ->
      if retries_count < 3 do
        :timer.sleep(1000)
        get_urls({site_key, url}, retries_count + 1)
      else
        {site_key, []}
      end
    _ ->
      {site_key, []}
  end

  def crawl(pid, {site_key, url}) do
    Task.async fn ->
      GenServer.call(pid, {site_key, url}, :infinity)
    end
  end
end
