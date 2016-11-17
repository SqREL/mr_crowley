defmodule MrCrowley.UrlNormalizer do
  def normalize({site_key, url}) do
    { site_key,
      URI.parse(url)
      |> Map.merge(%{fragment: nil})
      |> full_url_for(site_key)
      |> URI.to_string
      |> cleanup_processed(site_key)
    }
  end

  @base_urls %{"dk" => "https://lokalebasen.dk"}

  def puts()

  def full_url_for(url, site_key) do
    %{authority: base_authority, port: port, host: host, scheme: scheme} = URI.parse(@base_urls[site_key])

    case url do
      %{authority: nil} ->
        Map.merge(url, %{authority: base_authority, port: port, host: host, scheme: scheme})
      %{authority: ^base_authority} ->
        url
      _ ->
        %URI{authority: base_authority, port: port, host: host, scheme: scheme}
    end
  end

  def cleanup_processed(url, site_key) do
    case MrCrowley.RedisRepo.already_added?(site_key, url) do
      false -> url
       _  -> nil
    end
  end
end
