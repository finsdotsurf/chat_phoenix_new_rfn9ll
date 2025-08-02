# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ChatApp.Repo.insert!(%ChatApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ChatApp.Accounts

# Create a test user for easy login
{:ok, user} = Accounts.register_user(%{email: "test@example.com", password: "password123456"})
IO.puts("Created test user: #{user.email}")
