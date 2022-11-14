defmodule PirateXchangeWeb.Schema do
  use Absinthe.Schema
  alias PirateXchangeWeb.Middlewares.Errors

  import_types PirateXchangeWeb.Types.Currency
  import_types PirateXchangeWeb.Types.Transfer
  import_types PirateXchangeWeb.Types.User
  import_types PirateXchangeWeb.Types.UserTotalWorth
  import_types PirateXchangeWeb.Types.Wallet
  import_types PirateXchangeWeb.Schema.Queries.User
  import_types PirateXchangeWeb.Schema.Queries.Wallet
  import_types PirateXchangeWeb.Schema.Queries.UserTotalWorth
  import_types PirateXchangeWeb.Schema.Mutations.User
  import_types PirateXchangeWeb.Schema.Mutations.Wallet
  import_types PirateXchangeWeb.Schema.Subscriptions.UserTotalWorthChange

  query do
    import_fields :user_queries
    import_fields :user_total_worth_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  subscription do
    import_fields :total_worth_subscriptions
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(PirateXchange.Repo)

    dataloader =
      Dataloader.new
      |> Dataloader.add_source(PirateXchange.Accounts, source)
      |> Dataloader.add_source(PirateXchange.Wallets, source)

    Map.put(ctx, :loader, dataloader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _, %{identifier: identifier})
      when identifier in [:query, :subscription, :mutation] do
    middleware ++ [Errors]
  end

  def middleware(middleware, _, _) do
    middleware
  end
end
