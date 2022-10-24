defmodule PirateXchange.FxRates.FxRateApiStub do
  @spec get_rate(:atom, :atom, true | false) :: {:ok, String.t} | {:error, :atom}
  def get_rate(_from_currency, _to_currency, happy_path \\ true) do
    case happy_path do
      true -> {:ok, "42.42"}
      false -> {:error, :not_happy}
    end
  end
end
