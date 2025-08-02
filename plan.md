# Chat App Plan - Modern & Minimal Design

- [x] Generate a Phoenix LiveView project called `chat_app`
- [x] Create our detailed plan.md and start the server
- [ ] Replace the home page with a static mockup of our modern & minimal chat design
- [ ] Create migration for messages table with user_id, content, and timestamps
- [ ] Implement the Chat context and Message schema
  - Chat.list_messages/0 - returns all messages with preloaded user data
  - Chat.create_message/1 - creates a new message and broadcasts via PubSub
- [ ] Implement ChatLive LiveView with real-time messaging
  - Handle "send_message" event to create and broadcast messages
  - Subscribe to "chat:messages" PubSub topic for real-time updates
  - Use streams for efficient message rendering
- [ ] Create chat_live.html.heex template with modern & minimal design
  - Full-height chat interface with message list and input form
  - Clean typography and subtle shadows
  - Responsive design with proper spacing
- [ ] Update root.html.heex to force light theme and match our minimal design
- [ ] Update <Layouts.app> component to remove default header and match our design
- [ ] Update app.css with our modern & minimal color palette and styles
- [ ] Add user authentication with phx.gen.auth
- [ ] Seed a test user for easy login
- [ ] Update router to require authentication and replace home route with chat
- [ ] Visit the running app to verify real-time messaging works
- [ ] Final testing and polish

Target: Clean, modern interface with real-time messaging and minimal visual noise.
