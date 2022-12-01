defmodule PirateXchange.FxRates.FxRateApi do
  alias PirateXchange.FxRates.FxRate

  @fx_api_url PirateXchange.Config.fx_api_url

  @spec get_rate(atom, atom, String.t) :: {:ok, FxRate.t} | ErrorMessage.t
  def get_rate(from_currency, to_currency, url \\ @fx_api_url)

  def get_rate(from_currency, to_currency, _url) when from_currency === to_currency do
    {:ok, %FxRate{from_currency: from_currency, to_currency: to_currency, rate: "1.00"}}
  end

  def get_rate(from_currency, to_currency, url) do
    with res     <- fetch_from_external_api(from_currency, to_currency, url),
         {:ok, decoded} <- handle_response(res)
    do
      rate = %FxRate{
          from_currency: from_currency,
          to_currency: to_currency,
          rate: decoded
      }

      {:ok, rate}
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec fetch_from_external_api(atom, atom, String.t) :: {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}
  def fetch_from_external_api(from_currency, to_currency, url) do
    HTTPoison.get(url, [],
      params: [
        function: "CURRENCY_EXCHANGE_RATE",
        from_currency: from_currency,
        to_currency: to_currency
      ])
  end

  @spec handle_response(any) :: {:ok, String.t} | {:error, ErrorMessage.t}

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    maybe_ok_response(body)
  end

  defp handle_response({:ok, %{status_code: 400}}) do
    {:error, ErrorMessage.gateway_timeout("fx rate server timeout")}
  end

  defp handle_response({:error, %{reason: :econnrefused}}) do
    {:error, ErrorMessage.gateway_timeout("fx rate server timeout")}
  end

  defp handle_response({:error, %{reason: :timeout}}) do
    {:error, ErrorMessage.gateway_timeout("fx rate server timeout")}
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
