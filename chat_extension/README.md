# Dark Chat Extension

A sleek dark mode browser extension that connects to your Phoenix chat app, allowing you to chat from any website.

## Features

- 🌑 **Dark Mode Design** - Modern, professional dark interface
- 💬 **Real-time Chat** - Instant messaging with WebSocket connection
- 🔐 **Secure Authentication** - Token-based auth with your Phoenix backend
- 📱 **Compact Popup** - Clean 350px popup interface
- 🔄 **Auto-reconnect** - Handles connection drops gracefully
- 💾 **Message History** - Stores recent messages locally

## Installation

### Development Mode (Chrome)

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top right
3. Click "Load unpacked"
4. Select the `chat_extension` folder
5. The Dark Chat extension icon should appear in your toolbar

### Development Mode (Firefox)

1. Open Firefox and navigate to `about:debugging`
2. Click "This Firefox" in the sidebar
3. Click "Load Temporary Add-on"
4. Navigate to the `chat_extension` folder and select `manifest.json`
5. The extension will be loaded temporarily

## Usage

1. **Start your Phoenix chat app**: Make sure your Phoenix server is running on `localhost:4000`
2. **Click the extension icon** in your browser toolbar
3. **Sign in** with your chat app credentials:
   - Email: `test@example.com`
   - Password: `password123456`
4. **Start chatting!** Messages sync in real-time across all connected clients

## Technical Details

- **Backend API**: Connects to Phoenix app at `http://localhost:4000/api/auth/*`
- **WebSocket**: Real-time messaging via `ws://localhost:4000/socket/websocket`
- **Authentication**: JWT tokens with Phoenix.Token
- **CORS**: Configured for `chrome-extension://*` and `moz-extension://*` origins
- **Storage**: Uses Chrome's local storage for session persistence

## Files Structure

```
chat_extension/
├── manifest.json       # Extension configuration
├── popup.html         # Dark mode chat interface
├── popup.css          # Dark theme styling
├── popup.js           # UI interactions and auth
├── background.js      # WebSocket management
├── icons/             # Extension icons
└── README.md          # This file
```

## Development

The extension is ready to use in development mode. For production deployment, you would need to:

1. Create proper icons (currently using placeholders)
2. Update manifest.json with production URLs
3. Package for Chrome Web Store or Firefox Add-ons
4. Configure proper CSP policies

Enjoy your dark mode chat extension! 🚀
