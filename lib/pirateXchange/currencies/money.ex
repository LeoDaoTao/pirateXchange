defmodule PirateXchange.Currencies.Money do
  @enforce_keys [:code, :amount]
  defstruct(
    code: :USD,
    amount: "0.00"
  )

  @type t :: %__MODULE__{
    code: atom,
    amount: String.t
  }

  # convert integer pips to decimal pips in string form
  # for display use only
  # app uses 2 digit pips instead of standard FX 4 digit pips
  @spec to_pips(integer) :: String.t
  def to_pips(amount) do
    amount
    |> Kernel./(100)
    |> :erlang.float_to_binary(decimals: 2)
  end

  @spec string_to_integer_pips(String.t) :: integer
  def string_to_integer_pips(numeric_string) do
    numeric_string
    |> ensure_decimal_point()
    |> ensure_2_pips()
    |> String.replace(".", "")
    |> String.to_integer
  end

  @spec ensure_decimal_point(String.t) :: String.t
  defp ensure_decimal_point(numeric_string) do
    case String.contains?(numeric_string, ".") do
      true -> numeric_string
      _    -> numeric_string <> ".00"
    end
  end

  @spec ensure_2_pips(String.t) :: String.t
  defp ensure_2_pips(numeric_string) do
    [whole, decimal] = String.split(numeric_string, ".")
    "#{whole}.#{ensure_2_digits(decimal)}"
  end

  #if used in production it should have proper rounding
  @spec ensure_2_digits(String.t) :: String.t
  defp ensure_2_digits(numeric_string) do
    numeric_string
    |> String.slice(0..1)
    |> String.pad_trailing(2, "0")
  end
end
