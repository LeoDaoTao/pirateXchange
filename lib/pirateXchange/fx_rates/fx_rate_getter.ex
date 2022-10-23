defmodule PirateXchange.FxRates.FxRateGetter do
  alias PirateXchange.Currencies.Currency
  @fx_api Application.compile_env(:pirateXchange, :fx_api)

  @type currency :: Currency.t

  @spec get_rate(currency, currency) :: {:ok, String.t} | {:error, :atom}
  def get_rate(from_currency, to_currency) do
    from_currency
    |> http_fx_rate_request(to_currency)
    |> handle_response()
  end

  defp http_fx_rate_request(from_currency, to_currency) do
    HTTPoison.get(@fx_api, [],
      params: [
        function: "CURRENCY_EXCHANGE_RATE",
        from_currency: from_currency,
        to_currency: to_currency
      ])
  end

  defp handle_response(res) do
    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> maybe_ok_response(body)
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      _error -> {:error, :unknown_error}
    end
  end

  defp maybe_ok_response(body) do
    case Jason.decode(body) do
      {:ok, %{"Realtime Currency Exchange Rate" => data}} -> format_response(data)
      _error -> {:error, :json_decoding_error}
    end
  end

  def format_response( %{"5. Exchange Rate" => rate}), do: {:ok, rate}
end
