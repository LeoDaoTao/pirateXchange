defmodule PirateXchangeWeb.Resolvers.User do
  alias PirateXchange.Accounts

  #@type find(map, Absinthe.Resolution.t) ::
  def find(params, _resolution), do: Accounts.find_user(params)

  def create_user(params, _resolution), do: Accounts.create_user(params)

  def update_user(params, _resolution), do: Accounts.update_user(params)
end
