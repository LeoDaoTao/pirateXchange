defmodule PirateXchangeWeb.Schema.UserTest do
  use PirateXchange.DataCase, async: true
  alias PirateXchangeWeb.Schema

  import PirateXchange.UserFixtures, only: [users: 1, wallets: 1]

  @user_doc """
    query User($id: ID!){
      user(id: $id) {
        id
        name
        email
        wallets {
          integerAmount
          currency
        }
      }
    }
  """

  describe "@user" do
    setup [:users, :wallets]

    test "should return a user with valid wallets", ctx do
      assert {:ok, %{data: data}} = Absinthe.run(@user_doc, Schema,
        variables: %{
          "id" => ctx.user1.id
        }
      )

      assert data["user"]["name"] === ctx.user1.name
      assert data["user"]["email"] === ctx.user1.email

      assert data["user"]["wallets"] === convert_wallet_struct(ctx.user1_wallets)
    end
  end

  defp convert_wallet_struct(wallets) do
    Enum.map(wallets, fn wallet ->
      %{"currency" => Atom.to_string(wallet.currency), "integerAmount" => wallet.integer_amount }
    end)
  end
end
