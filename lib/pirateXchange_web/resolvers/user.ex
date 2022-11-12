defmodule PirateXchangeWeb.Resolvers.User do
  alias PirateXchange.Accounts

  #@type find(map, Absinthe.Resolution.t) ::
  def find(params, _resolution), do: Accounts.find_user(params)
end
