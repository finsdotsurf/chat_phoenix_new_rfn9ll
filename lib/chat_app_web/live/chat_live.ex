defmodule ChatAppWeb.ChatLive do
  use ChatAppWeb, :live_view

  alias ChatApp.Chat
  alias ChatApp.Chat.Message

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(ChatApp.PubSub, "chat:messages")
    end

    messages = Chat.list_messages()

    {:ok,
     socket
     |> assign(:messages_empty?, messages == [])
     |> assign(:form, to_form(Chat.change_message(%Message{})))
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
  def handle_event("send_message", %{"message" => message_params}, socket) do
    current_user = socket.assigns.current_scope.user

    message_params =
      Map.merge(message_params, %{
        "user_id" => current_user.id,
        "username" => String.split(current_user.email, "@") |> List.first() |> String.capitalize()
      })

    case Chat.create_message(message_params) do
      {:ok, message} ->
        {:noreply,
         socket
         |> assign(:messages_empty?, false)
         |> assign(:form, to_form(Chat.change_message(%Message{})))
         |> stream_insert(:messages, message)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply,
     socket
     |> assign(:messages_empty?, false)
     |> stream_insert(:messages, message)}
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
