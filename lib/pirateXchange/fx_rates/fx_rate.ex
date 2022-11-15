defmodule PirateXchange.FxRates.FxRate do
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.FxRates.FxRateApi

  @fx_api_url Application.get_env(:pirateXchange, :fx_api_url)

  @enforce_keys [:from_currency, :to_currency, :rate]
  defstruct [:from_currency, :to_currency, :rate]

  @type t :: %__MODULE__{
    from_currency: Currency.t,
    to_currency: Currency.t,
    rate: String.t
  }

  @spec get_rate(atom, atom, String.t ) :: {:ok, t} | {:error, ErrorMessage.t}
  def get_rate(from_currency, to_currency, url \\ @fx_api_url) do
    case FxRateApi.get_rate(from_currency, to_currency, url) do
      {:ok, res} ->
        {:ok, %__MODULE__{
          from_currency: from_currency,
          to_currency: to_currency,
          rate: res
          }
        }

      {:error, %ErrorMessage{
        code: :gateway_timeout,
        message: "fx rate server timeout"}
          = error} ->
        {:error, error}

      {:error, %ErrorMessage{
        code: :internal_server_error,
        message: "json decoding error"}
          = error} ->
        {:error, error}
    end
  end
end
