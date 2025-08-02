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

# Create multiple test users for easy login and testing
users = [
  {email: "test@example.com", password: "password123456"},
  {email: "alice@example.com", password: "password123456"},
  {email: "bob@example.com", password: "password123456"},
  {email: "charlie@example.com", password: "password123456"},
  {email: "diana@example.com", password: "password123456"}
]

Enum.each(users, fn {email: email, password: password} ->
  case Accounts.get_user_by_email(email) do
    nil ->
      {:ok, user} = Accounts.register_user(%{email: email, password: password})
      IO.puts("Created user: #{user.email}")
    
    _existing_user ->
      IO.puts("User already exists: #{email}")
  end
end)

IO.puts("\nTest users created! You can log in with:")
IO.puts("- test@example.com / password123456")
IO.puts("- alice@example.com / password123456") 
IO.puts("- bob@example.com / password123456")
IO.puts("- charlie@example.com / password123456")
IO.puts("- diana@example.com / password123456")
