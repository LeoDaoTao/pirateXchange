defmodule PirateXchange.Currencies.MoneyTest do
  use ExUnit.Case

  alias PirateXchange.Currencies.Money

  describe "add/2" do
    test "should add two Money values of the same currency" do
      assert Money.add(
        %Money{code: :usd, amount: "1.0000"},
        %Money{code: :usd, amount: "2.0000"}
      ) ===
        %Money{code: :usd, amount: "3.0000"}

      assert Money.add(
        %Money{code: :cdn, amount: "1.1234"},
        %Money{code: :cdn, amount: "2.5678"}
      ) ===
        %Money{code: :cdn, amount: "3.6912"}
    end

    test "shuld return 4 digit pip value even if 4 digit pips where not supplied" do
      assert Money.add(
        %Money{code: :usd, amount: "1.0"},
        %Money{code: :usd, amount: "2.0000"}
      ) ===
        %Money{code: :usd, amount: "3.0000"}

      assert Money.add(
        %Money{code: :cdn, amount: "1.0000"},
        %Money{code: :cdn, amount: "2.0"}
      ) ===
        %Money{code: :cdn, amount: "3.0000"}

      assert Money.add(
        %Money{code: :pln, amount: "1.0000"},
        %Money{code: :pln, amount: "2.0"}
      ) ===
        %Money{code: :pln, amount: "3.0000"}

      assert Money.add(
        %Money{code: :pln, amount: "1.32"},
        %Money{code: :pln, amount: "2.333"}
      ) ===
        %Money{code: :pln, amount: "3.6530"}

      assert Money.add(
        %Money{code: :usd, amount: "1"},
        %Money{code: :usd, amount: "2"}
      ) ===
        %Money{code: :usd, amount: "3.0000"}
    end
  end
end
