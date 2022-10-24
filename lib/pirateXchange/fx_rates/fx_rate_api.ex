defmodule PirateXchange.FxRates.FxRateApi do
  @fx_api_url Application.compile_env(:pirateXchange, :fx_api_url)

  @spec get_rate(:atom, :atom, any | :live_api) :: {:ok, String.t} | {:error, :atom}
  def get_rate(from_currency, to_currency, injected_res \\ :live_api) do
    case injected_res do
      :live_api ->
        from_currency
        |> fetch_from_live_api(to_currency)
        |> handle_response()

      _ -> handle_response(injected_res)
    end
  end

  @spec fetch_from_live_api(:atom, :atom) :: {:ok, HTTPoison.Response.t} | {:error, :atom}
  defp fetch_from_live_api(from_currency, to_currency) do
    HTTPoison.get(@fx_api_url, [],
      params: [
        function: "CURRENCY_EXCHANGE_RATE",
        from_currency: from_currency,
        to_currency: to_currency
      ])
  end

  @spec handle_response(any) :: {:ok, String.t} | {:error, :atom}
  defp handle_response(res) do
    case res do
      {:ok, %{status_code: 200, body: body}} -> maybe_ok_response(body)
      {:error, %{reason: reason}} -> {:error, reason}
      _error -> {:error, :unknown_error}
    end
  end

  @spec maybe_ok_response(String.t) :: {:ok, String.t} | {:error, :atom}
  defp maybe_ok_response(body) do
    case Jason.decode(body) do
      {:ok, %{"Realtime Currency Exchange Rate" => data}} -> {:ok, format_response(data)}
      _error -> {:error, :json_decoding_error}
    end
  end

  @spec format_response(map) :: String.t
  defp format_response(%{"5. Exchange Rate" => rate}), do: rate
end
