defmodule PirateXchange.Currencies do
  @available_currencies Application.get_env(:pirateXchange, :available_currencies)

  def available(), do: @available_currencies
end
