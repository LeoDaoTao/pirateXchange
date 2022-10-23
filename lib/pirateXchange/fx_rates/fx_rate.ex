defmodule PirateXchange.FxRates.FxRate do
  alias PirateXchange.Currencies.Currency

  @enforce_keys [:from_currency, :to_currency, :rate]
  defstruct [:from_currency, :to_currency, :rate]

  @type t :: %__MODULE__{
    from_currency: Currency.t,
    to_currency: Currency.t,
    rate: String.t
  }

  @opaque currency :: Currency.t

  @spec get_rate(currency, currency) :: t
  def get_rate(from_currency, to_currency) do
    %__MODULE__{
      from_currency: from_currency,
      to_currency: to_currency,
      rate: get_live_fx_rate(from_currency, to_currency)
    }
  end

  @spec get_live_fx_rate(currency, currency) :: String.t
  defp get_live_fx_rate(from_currency, to_currency) do
    #Fetch rate from fx_getter
    #return as string
    "1.0000"
  end
end
