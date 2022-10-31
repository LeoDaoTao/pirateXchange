defmodule PirateXchange.WalletsFixtures do
  alias PirateXchange.Accounts

  @user_params %{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}
  @user_2_params %{name: "Black Beard", email: "black@queensrevenge.com"}
  @wallet_params %{}

  def user(_ctx) do
    {:ok, user} = Accounts.create_user(@user_params)

    %{user: user}
  end
end
