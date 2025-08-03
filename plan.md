# URL-Based Chat Rooms Plan - Modern Social Design

## Completed ✅
- [x] Basic chat app with authentication
- [x] Real-time messaging via PubSub
- [x] User system with test accounts

## Room System Implementation 🚀
- [ ] **Step 1**: Create Room schema and migration (url, name, description, user_id as creator)
- [ ] **Step 2**: Update Message schema to belong to a room (add room_id foreign key) 
- [ ] **Step 3**: Create Rooms context for CRUD operations (create_room, list_rooms, get_room_by_url)
- [ ] **Step 4**: Update ChatLive to handle room selection and current room state
- [ ] **Step 5**: Add room creation form with URL input to chat interface
- [ ] **Step 6**: Update message broadcasting to be room-scoped (PubSub topics per room)
- [ ] **Step 7**: Update chat template with modern social design - card-based room switcher
- [ ] **Step 8**: Add URL validation and auto room name generation (extract domain/title)
- [ ] **Step 9**: Update layouts to match modern social vibrant design
- [ ] **Step 10**: Seed example rooms for testing (popular websites)
- [ ] **Step 11**: Test multi-room functionality with multiple users
- [ ] **Step 12**: Polish UI - room cards, gradients, modern social styling
- [ ] **Step 13**: Add room discovery and join flow
- [ ] **Step 14**: Final testing and verification

## Modern Social Design Features 🎨
- **Vibrant color gradients** and modern card-based layouts
- **Room cards** with website favicons and member counts
- **Floating action buttons** for creating new rooms
- **Instagram-style** message bubbles and user avatars
- **Dynamic room switching** with smooth transitions

## Technical Architecture 🏗️
- Rooms: id, url (unique), name, description, user_id (creator), inserted_at
- Messages: room_id foreign key, scoped to specific rooms
- PubSub: `"chat:room:#{room_id}"` topics for real-time room updates
- URL normalization and validation for consistent room creation
