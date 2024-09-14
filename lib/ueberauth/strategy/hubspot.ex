defmodule Ueberauth.Strategy.Hubspot do
  @moduledoc """
  HubSpot Strategy for Überauth.
  """

  use Ueberauth.Strategy, uid_field: :id, default_scope: "default"

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles initial request for HubSpot authentication.
  """
  def handle_request!(conn) do
    scopes = build_scopes(conn)

    opts =
      [scope: scopes]
      |> with_state_param(conn)
      |> Keyword.put(:redirect_uri, callback_url(conn))

    redirect!(conn, Ueberauth.Strategy.Hubspot.OAuth.authorize_url!(opts))
  end

  defp build_scopes(conn) do
    conn.params["scope"] || app_env(:default_scope) || option(conn, :default_scope)
  end

  defp app_env(key) do
    case Application.get_env(:ueberauth, __MODULE__) do
      nil ->
        nil

      env ->
        env[key]
    end
  end

  @doc false
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = [redirect_uri: callback_url(conn)]
    token = Ueberauth.Strategy.Hubspot.OAuth.get_token!([code: code], opts)

    if token.access_token == nil do
      err = token.other_params["error"]
      desc = token.other_params["error_description"]
      set_errors!(conn, [error(err, desc)])
    else
      conn
      |> store_token(token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:hubspot_token, nil)
  end

  # Store the token for later use.
  @doc false
  defp store_token(conn, token) do
    put_private(conn, :hubspot_token, token)
  end

  defp split_scopes(token) do
    (token.other_params["scope"] || "")
    |> String.split(" ")
  end

  @doc """
  Includes the credentials from the HubSpot response.
  """
  def credentials(conn) do
    token = conn.private.hubspot_token
    scopes = split_scopes(token)

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      refresh_token: token.refresh_token,
      token: token.access_token
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    token = conn.private.hubspot_token

    %Info{
      name: get_data(token, "name"),
      email: get_data(token, "email"),
    }
  end

  @doc """
  Stores the raw information (including the token & user)
  obtained from the HubSpot callback.
  """
  def extra(conn) do
    %{
      hubspot_token: :token,
    }
    |> Enum.filter(fn {original_key, _} ->
      Map.has_key?(conn.private, original_key)
    end)
    |> Enum.map(fn {original_key, mapped_key} ->
      {mapped_key, Map.fetch!(conn.private, original_key)}
    end)
    |> Map.new()
    |> (&%Extra{raw_info: &1}).()
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    get_data(conn.private.hubspot_token, uid_field)
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end

  defp get_data(token, field) do
    token.other_params["data"][field]
  end
end
