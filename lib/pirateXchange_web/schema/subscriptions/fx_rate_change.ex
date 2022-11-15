defmodule PirateXchangeWeb.Schema.Subscriptions.FxRateChange do
  use Absinthe.Schema.Notation

  object :fx_rate_subscriptions do
    @desc "Broadcasts fx rate changes"
    field :fx_rate_change, :fx_rate do
      arg :currency, :currency

      config fn
        %{currency: currency}, _ctx ->
          {:ok, topic: "fx_rate_change:#{currency}"}

        _args, _ctx ->
          {:ok, topic: "fx_rate_change:all"}
      end
    end
  end
end
