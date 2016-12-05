defmodule MrCrowley.Parser do
  def parse({site_key, body}) do
    { site_key,
      body
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.map(fn link ->
        {site_key, normalized_url} = MrCrowley.UrlNormalizer.normalize({site_key, link})
        normalized_url
      end)
      |> Enum.filter(&(!is_nil(&1)))}
  end
end
