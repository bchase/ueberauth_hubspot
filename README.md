# Überauth Asana

> Asana OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [Asana Developers](https://developers.asana.com/docs/oauth).

1. Add `:ueberauth_asana` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_asana, "~> 0.1"}]
    end
    ```

1. Add Asana to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        asana: {Ueberauth.Strategy.Asana, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Asana.OAuth,
      client_id: System.get_env("ASANA_CLIENT_ID"),
      client_secret: System.get_env("ASANA_CLIENT_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

    And make sure to set the correct redirect URI(s) in your Asana application to wire up the callback.

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

### Auth

Depending on the configured url you can initialize the request through:

    /auth/asana

Or with options:

    /auth/asana?scope=openid%20email

By default the requested scope is "default". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    asana: {Ueberauth.Strategy.Asana, [default_scope: "default"]}
    # asana: {Ueberauth.Strategy.Asana, [default_scope: "default openid email profile"]}
  ]
```
