defmodule PirateXchangeWeb.Types.FxRate do
  use Absinthe.Schema.Notation

  @desc "Fx Rates"
  object :fx_rate do
    field :from_currency, non_null(:currency)
    field :to_currency, non_null(:currency)
    field :rate, non_null(:string)
  end
end
