defmodule PirateXchange.UsersFixtures do
  alias PirateXchange.Accounts
  alias PirateXchange.Accounts.User
  alias PirateXchange.Repo

  @user_params %{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}
  @user2_params %{name: "Blackbeard", email: "unshaven@queensrevenge.com"}

  def user(_ctx) do
    {:ok, user} = Accounts.create_user(@user_params)
    %{user: user}
  end

  def users(_ctx) do
    Accounts.create_user(@user_params)
    Accounts.create_user(@user2_params)
    %{users: Repo.all(User)}
  end
end
