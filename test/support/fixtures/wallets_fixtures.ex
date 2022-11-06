defmodule PirateXchange.WalletsFixtures do
  alias PirateXchange.Accounts
  alias PirateXchange.Wallets

  @user_params %{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}
  @user_deleted_params %{name: "No Name", email: "no@pirate.com"}
  @user2_params %{name: "Calico Jack", email: "calico@thekingston.com"}
  @user_no_wallet_params %{name: "Blackbeard", email: "unshaven@queensrevenge.com"}

  def user(_ctx) do
    {:ok, user} = Accounts.create_user(@user_params)
    %{user: user}
  end

  def user2(_ctx) do
    {:ok, user} = Accounts.create_user(@user2_params)
    %{user2: user}
  end

  def user_no_wallet(_ctx) do
    {:ok, user} = Accounts.create_user(@user_no_wallet_params)
    %{user_no_wallet: user}
  end

  def user_deleted(_ctx) do
    {:ok, user} = Accounts.create_user(@user_deleted_params)
    {:ok, user} = Accounts.delete_user(user.id)
    %{user_deleted: user}
  end

  def wallet(%{user: user}) do
    {:ok, wallet} = Wallets.create_wallet(%{user_id: user.id, currency: :USD, integer_amount: 1000})
    %{wallet: wallet}
  end

  def wallets(%{user: user}) do
    {:ok, wallet_usd} = Wallets.create_wallet(%{user_id: user.id, currency: :USD, integer_amount: 1000})
    {:ok, wallet_pln} = Wallets.create_wallet(%{user_id: user.id, currency: :PLN, integer_amount: 1000})
    %{wallets: [wallet_usd, wallet_pln]}
  end

  def wallets2(%{user2: user}) do
    {:ok, wallet_usd} = Wallets.create_wallet(%{user_id: user.id, currency: :USD, integer_amount: 1000})
    {:ok, wallet_pln} = Wallets.create_wallet(%{user_id: user.id, currency: :PLN, integer_amount: 1000})
    %{wallets: [wallet_usd, wallet_pln]}
  end
end
