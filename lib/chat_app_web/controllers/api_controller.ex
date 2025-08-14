defmodule ChatAppWeb.ApiController do
  use ChatAppWeb, :controller

  alias ChatApp.Accounts

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %ChatApp.Accounts.User{} = user ->
        # Generate a token for the extension
        token = Phoenix.Token.sign(conn, "user auth", user.id)

        conn
        |> put_status(:ok)
        |> json(%{
          token: token,
          user: %{
            id: user.id,
            email: user.email,
            username: user.email |> String.split("@") |> hd()
          }
        })

      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Email and password are required"})
  end

  def logout(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Logged out successfully"})
  end

  def me(conn, _params) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Phoenix.Token.verify(conn, "user auth", token, max_age: 86400),
         %ChatApp.Accounts.User{} = user <- Accounts.get_user!(user_id) do
      conn
      |> put_status(:ok)
      |> json(%{
        user: %{
          id: user.id,
          email: user.email,
          username: user.email |> String.split("@") |> hd()
        }
      })
    else
      [] ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authorization header missing"})

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired token"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end
end
