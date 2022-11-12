defmodule PirateXchangeWeb.Schema do
  use Absinthe.Schema

  import_types PirateXchangeWeb.Types.Currency
  import_types PirateXchangeWeb.Types.User
  import_types PirateXchangeWeb.Types.UserTotalWorth
  import_types PirateXchangeWeb.Schema.Queries.User
  import_types PirateXchangeWeb.Schema.Queries.UserTotalWorth
  import_types PirateXchangeWeb.Types.Wallet
  import_types PirateXchangeWeb.Schema.Queries.Wallet

  query do
    import_fields :user_queries
    import_fields :user_total_worth_queries
    import_fields :wallet_queries
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
end
