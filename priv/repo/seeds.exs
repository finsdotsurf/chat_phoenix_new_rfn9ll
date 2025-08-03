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

alias ChatApp.{Accounts, Chat, Repo}

# Create test users if they don't exist
test_users = [
  %{email: "test@example.com"},
  %{email: "alice@example.com"},
  %{email: "bob@example.com"},
  %{email: "charlie@example.com"},
  %{email: "diana@example.com"}
]

for user_attrs <- test_users do
  case Accounts.get_user_by_email(user_attrs.email) do
    nil ->
      {:ok, user} = Accounts.register_user(user_attrs)

      {:ok, _user, _expired_tokens} =
        Accounts.update_user_password(user, %{password: "password123456"})

      IO.puts("Created user: #{user_attrs.email}")

    _user ->
      IO.puts("User already exists: #{user_attrs.email}")
  end
end

# Get the first user to be the creator of example rooms
creator = Accounts.get_user_by_email("test@example.com")

# Create example rooms for popular websites
example_rooms = [
  %{url: "https://github.com", name: "GitHub", description: "Discuss code and projects"},
  %{
    url: "https://news.ycombinator.com",
    name: "Hacker News",
    description: "Tech news and discussions"
  },
  %{url: "https://reddit.com", name: "Reddit", description: "General discussions and memes"},
  %{url: "https://stackoverflow.com", name: "Stack Overflow", description: "Programming Q&A"},
  %{url: "https://youtube.com", name: "YouTube", description: "Video discussions"},
  %{url: "https://twitter.com", name: "Twitter", description: "Social media chatter"}
]

for room_attrs <- example_rooms do
  room_attrs = Map.put(room_attrs, :user_id, creator.id)

  case Chat.get_room_by_url(room_attrs.url) do
    nil ->
      {:ok, room} = Chat.create_room(room_attrs)
      IO.puts("Created room: #{room.name} - #{room.url}")

    _room ->
      IO.puts("Room already exists: #{room_attrs.name}")
  end
end

IO.puts("Seeding completed!")
