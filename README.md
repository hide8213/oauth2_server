# Oauth2Server

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Setup Env
1. Change defalut mysql connect config in dev.exs.
2. Change Redis connect config in dev.exs.

How to use
1. Now we have two default Resource Owner - client_credentials, password.
2. When you build up the oauth server, you can get access token from [`localhost:4000/auth/token`](http://localhost:4000/auth/token).
3. Generate oauth_client table and insert application_id, secret to map http header - Authorization.
4. No user info to access client_credentials grant type or user's email, password to access password grant type.
5. The access token is used redis server to control the authentication, the benifit is when user access restful apis by using access token, it will be mapping by redis cache data, not in session.

Customize Resource Owner
1. Authenticator.ex is the core file to fire resource owner.
2. The default client credentials grant type will not provide refresh token.
3. The default password grant type will provide refresh token.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
  * OAuth2: http://oauth.net/2/
