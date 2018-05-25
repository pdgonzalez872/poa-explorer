defmodule Explorer.SmartContract.Solidity.CompilerVersion do
  @moduledoc """
  Adapter for fetching compiler versions from https://solc-bin.ethereum.org/bin/list.json.
  """

  alias HTTPoison.{Error, Response}

  @doc """
  Fetches a list of compilers from the Ethereum Solidity API.
  """
  @spec fetch_versions :: {atom, [map]}
  def fetch_versions do
    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.get(source_url(), headers) do
      {:ok, %Response{body: body, status_code: 200}} ->
        {:ok, format_data(body)}

      {:ok, %Response{body: body, status_code: status_code}} when status_code in 400..499 ->
        {:error, decode_json(body)["error"]}

      {:error, %Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp format_data(json) do
    {:ok, releases} =
      json
      |> Jason.decode!()
      |> Map.fetch("releases")

    releases
    |> Map.to_list()
    |> Enum.map(fn {key, _value} -> {key, key} end)
    |> Enum.sort()
    |> Enum.reverse()
  end

  defp decode_json(json) do
    Jason.decode!(json)
  end

  defp source_url do
    solc_bin_api_url = Application.get_env(:explorer, :solc_bin_api_url)

    "#{solc_bin_api_url}/bin/list.json"
  end
end
