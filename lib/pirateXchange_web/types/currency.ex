defmodule PirateXchangeWeb.Types.Currency do
  use Absinthe.Schema.Notation

  @available_currencies Application.get_env(:pirateXchange, :available_currencies)

  @desc "Currency codes that can be used by the application"
  enum :currency, values: @available_currencies
end
