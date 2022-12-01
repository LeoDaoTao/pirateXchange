defmodule PirateXchange.Config do
  @application :pirateXchange

  @spec available_currencies() :: [atom]
  def available_currencies, do: Application.get_env(@application, :available_currencies)

  @spec fx_api_url() :: String.t
  def fx_api_url, do: Application.get_env(@application, :fx_api_url)

  @spec fx_rate_cache() :: String.t
  def fx_rate_cache, do: Application.get_env(@application, :fx_rate_cache)

  @spec global_ttl() :: Integer
  def global_ttl, do: Application.get_env(@application, :global_ttl)

  @spec ttl_check_interval() :: Integer
  def ttl_check_interval, do: Application.get_env(:pirateXchange, :ttl_check_interval)

  @spec fx_rate_refresh_interval() :: Integer
  def fx_rate_refresh_interval, do: Application.get_env(:pirateXchange, :fx_rate_refresh_interval)
end
