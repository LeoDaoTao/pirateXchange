defmodule PirateXchange.FxRates.FxRateApi do
  @fx_api_url Application.get_env(:pirateXchange, :fx_api_url)

  @spec get_rate(:atom, :atom, String.t) :: {:ok, String.t} | ErrorMessage.t
  def get_rate(from_currency, to_currency, url \\ @fx_api_url)

  def get_rate(from_currency, to_currency, _url) when from_currency === to_currency do
    {:ok, "1"}
  end

  def get_rate(from_currency, to_currency, url) do
    from_currency
    |> fetch_from_external_api(to_currency, url)
    |> handle_response()
  end


  @spec fetch_from_external_api(:atom, :atom, String.t) :: {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}
  defp fetch_from_external_api(from_currency, to_currency, url) do
    HTTPoison.get(url, [],
      params: [
        function: "CURRENCY_EXCHANGE_RATE",
        from_currency: from_currency,
        to_currency: to_currency
      ])
  end

  @spec handle_response(any) :: {:ok, String.t} | {:error, ErrorMessage.t}
  defp handle_response(res) do
    case res do
      {:ok, %{status_code: 200, body: body}} ->
        maybe_ok_response(body)

      {:error, %{reason: :econnrefused}} ->
        {:error, ErrorMessage.gateway_timeout("fx rate server timeout")}
    end
  end

  @spec maybe_ok_response(String.t) :: {:ok, String.t} | {:error, ErrorMessage.t}
  defp maybe_ok_response(body) do
    case Jason.decode(body) do
      {:ok, %{"Realtime Currency Exchange Rate" => data}} ->
        {:ok, format_response(data)}

      _error ->
        {:error, ErrorMessage.internal_server_error("json decoding error")}
    end
  end

  @spec format_response(map) :: String.t
  defp format_response(%{"5. Exchange Rate" => rate}), do: rate
end
