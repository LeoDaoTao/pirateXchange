defmodule PirateXchange.UserFixtures do
  alias PirateXchange.Accounts
  alias PirateXchange.Accounts.User
  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Wallet
  alias PirateXchange.Repo

  @user_params %{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}
  @user2_params %{name: "Blackbeard", email: "unshaven@queensrevenge.com"}
  @user_deleted_params %{name: "No Name", email: "no@pirate.com"}
  @user_no_wallet_params %{name: "Calico Jack", email: "calico@thekingston.com"}

  def user_params(_ctx), do: %{user_params: @user_params}

  def users(_ctx) do
    {:ok, user1} = Accounts.create_user(@user_params)
    {:ok, user2} = Accounts.create_user(@user2_params)
    %{users: Repo.all(User), user1: user1, user2: user2}
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

  def wallets(%{user1: user1, user2: user2}) do
    {:ok, user1_wallet_usd} = Wallets.create_wallet(%{user_id: user1.id, currency: :USD, integer_amount: 10_000})
    {:ok, user1_wallet_pln} = Wallets.create_wallet(%{user_id: user1.id, currency: :PLN, integer_amount: 10_000})
    {:ok, user2_wallet_usd} = Wallets.create_wallet(%{user_id: user2.id, currency: :USD, integer_amount: 10_000})
    {:ok, user2_wallet_pln} = Wallets.create_wallet(%{user_id: user2.id, currency: :PLN, integer_amount: 10_000})

    %{
      user1_wallets: [user1_wallet_usd, user1_wallet_pln],
      user2_wallets: [user2_wallet_usd, user2_wallet_pln],
      wallets: Repo.all(Wallet)
    }
  end
end
