defmodule ChatAppWeb.ChatLive do
  use ChatAppWeb, :live_view

  alias ChatApp.Chat
  alias ChatApp.Chat.Message
  alias ChatApp.Chat.Room

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(ChatApp.PubSub, "chat:messages")
    end

    messages = Chat.list_messages()
    rooms = Chat.list_rooms()

    {:ok,
     socket
     |> assign(:messages_empty?, messages == [])
     |> assign(:rooms, rooms)
     |> assign(:current_room, nil)
     |> assign(:show_room_form, false)
     |> assign(:form, to_form(Chat.change_message(%Message{})))
     |> assign(:room_form, to_form(Room.changeset(%Room{}, %{})))
     |> stream(:messages, messages)}
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    changeset =
      %Message{}
      |> Chat.change_message(message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate_room", %{"room" => room_params}, socket) do
    changeset =
      %Room{}
      |> Room.changeset(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, room_form: to_form(changeset))}
  end

  @impl true
  def handle_event("send_message", %{"message" => message_params}, socket) do
    current_user = socket.assigns.current_scope.user
    current_room = socket.assigns.current_room

    if current_room do
      message_params =
        Map.merge(message_params, %{
          "user_id" => current_user.id,
          "username" =>
            String.split(current_user.email, "@") |> List.first() |> String.capitalize(),
          "room_id" => current_room.id
        })

      case Chat.create_message(message_params) do
        {:ok, message} ->
          Phoenix.PubSub.broadcast(
            ChatApp.PubSub,
            "chat:room:#{current_room.id}",
            {:new_message, message}
          )

          {:noreply,
           socket
           |> assign(:messages_empty?, false)
           |> assign(:form, to_form(Chat.change_message(%Message{})))
           |> stream_insert(:messages, message)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    else
      {:noreply, put_flash(socket, :error, "Please select a room first")}
    end
  end

  @impl true
  def handle_event("create_room", %{"room" => room_params}, socket) do
    current_user = socket.assigns.current_scope.user

    room_params = Map.put(room_params, "user_id", current_user.id)

    # Auto-generate room name from URL if not provided
    room_params =
      if Map.get(room_params, "name", "") == "" do
        name = extract_domain_name(room_params["url"])
        Map.put(room_params, "name", name)
      else
        room_params
      end

    case Chat.create_room(room_params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> assign(:rooms, [room | socket.assigns.rooms])
         |> assign(:show_room_form, false)
         |> assign(:room_form, to_form(Room.changeset(%Room{}, %{})))
         |> put_flash(:info, "Room created successfully!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, room_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("select_room", %{"id" => room_id}, socket) do
    room = Enum.find(socket.assigns.rooms, &(&1.id == String.to_integer(room_id)))

    if room do
      # Unsubscribe from old room if any
      if socket.assigns.current_room do
        Phoenix.PubSub.unsubscribe(ChatApp.PubSub, "chat:room:#{socket.assigns.current_room.id}")
      end

      # Subscribe to new room
      Phoenix.PubSub.subscribe(ChatApp.PubSub, "chat:room:#{room.id}")

      # Load messages for this room
      messages = Chat.list_messages_for_room(room.id)

      {:noreply,
       socket
       |> assign(:current_room, room)
       |> assign(:messages_empty?, messages == [])
       |> stream(:messages, messages, reset: true)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("toggle_room_form", _params, socket) do
    {:noreply, assign(socket, show_room_form: !socket.assigns.show_room_form)}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply,
     socket
     |> assign(:messages_empty?, false)
     |> stream_insert(:messages, message)}
  end

  defp extract_domain_name(url) do
    case URI.parse(url) do
      %URI{host: host} when not is_nil(host) ->
        host
        |> String.replace("www.", "")
        |> String.split(".")
        |> List.first()
        |> String.capitalize()

      _ ->
        "Unknown Site"
    end
  end

  defp format_timestamp(datetime) do
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> Calendar.strftime("%I:%M %p")
  end

  defp user_initials(username) do
    username
    |> String.split()
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
    |> String.slice(0, 2)
  end

  defp user_color(user_id) do
    colors = [
      "bg-blue-500",
      "bg-green-500",
      "bg-purple-500",
      "bg-pink-500",
      "bg-indigo-500",
      "bg-yellow-500"
    ]

    Enum.at(colors, rem(user_id, length(colors)))
  end
end
