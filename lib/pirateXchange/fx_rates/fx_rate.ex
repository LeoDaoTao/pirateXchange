defmodule PirateXchange.FxRates.FxRate do
  alias PirateXchange.Currencies.Currency

  @enforce_keys [:from_currency, :to_currency, :rate]
  defstruct [:from_currency, :to_currency, :rate]

  @type t :: %__MODULE__{
    from_currency: Currency.t,
    to_currency: Currency.t,
    rate: String.t
  }
end
