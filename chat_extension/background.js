// Background Service Worker for Dark Chat Extension
// Handles persistent WebSocket connections and message management

class ChatExtensionBackground {
  constructor() {
    this.socket = null;
    this.isConnected = false;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectDelay = 1000;
    this.authToken = null;
    this.currentUser = null;
    this.messageQueue = [];

    // Initialize on startup
    this.init();
  }

  async init() {
    console.log("Dark Chat Extension background initialized");

    // Load stored auth data
    await this.loadAuthData();

    // Set up message listeners
    this.setupMessageListeners();

    // Connect if we have auth data
    if (this.authToken) {
      this.connectWebSocket();
    }
  }

  async loadAuthData() {
    try {
      const result = await chrome.storage.local.get([
        "authToken",
        "currentUser",
      ]);
      this.authToken = result.authToken;
      this.currentUser = result.currentUser;
      console.log("Loaded auth data:", !!this.authToken);
    } catch (error) {
      console.error("Failed to load auth data:", error);
    }
  }

  async saveAuthData(token, user) {
    try {
      await chrome.storage.local.set({
        authToken: token,
        currentUser: user,
      });
      this.authToken = token;
      this.currentUser = user;
      console.log("Saved auth data for user:", user?.email);
    } catch (error) {
      console.error("Failed to save auth data:", error);
    }
  }

  async clearAuthData() {
    try {
      await chrome.storage.local.remove(["authToken", "currentUser"]);
      this.authToken = null;
      this.currentUser = null;
      this.disconnect();
      console.log("Cleared auth data");
    } catch (error) {
      console.error("Failed to clear auth data:", error);
    }
  }

  connectWebSocket() {
    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      console.log("WebSocket already connected");
      return;
    }

    if (!this.authToken) {
      console.log("No auth token available for WebSocket connection");
      return;
    }

    try {
      const wsUrl = `ws://localhost:4000/socket/websocket?token=${this.authToken}`;
      this.socket = new WebSocket(wsUrl);

      this.socket.onopen = () => {
        console.log("WebSocket connected to Phoenix chat");
        this.isConnected = true;
        this.reconnectAttempts = 0;
        this.notifyPopup({ type: "connection_status", connected: true });
        this.processMessageQueue();
      };

      this.socket.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          this.handleWebSocketMessage(data);
        } catch (error) {
          console.error("Failed to parse WebSocket message:", error);
        }
      };

      this.socket.onclose = () => {
        console.log("WebSocket disconnected");
        this.isConnected = false;
        this.notifyPopup({ type: "connection_status", connected: false });
        this.scheduleReconnect();
      };

      this.socket.onerror = (error) => {
        console.error("WebSocket error:", error);
        this.isConnected = false;
        this.notifyPopup({ type: "connection_error", error: error.message });
      };
    } catch (error) {
      console.error("Failed to create WebSocket connection:", error);
    }
  }

  handleWebSocketMessage(data) {
    console.log("Received WebSocket message:", data);

    switch (data.event) {
      case "new_message":
        this.notifyPopup({
          type: "new_message",
          message: data.payload,
        });
        break;
      case "user_joined":
        this.notifyPopup({
          type: "user_joined",
          user: data.payload,
        });
        break;
      case "user_left":
        this.notifyPopup({
          type: "user_left",
          user: data.payload,
        });
        break;
      default:
        console.log("Unknown WebSocket event:", data.event);
    }
  }

  sendMessage(message) {
    if (this.isConnected && this.socket) {
      this.socket.send(JSON.stringify(message));
    } else {
      // Queue message for when connection is restored
      this.messageQueue.push(message);
      console.log("Message queued (not connected):", message);
    }
  }

  processMessageQueue() {
    while (this.messageQueue.length > 0 && this.isConnected) {
      const message = this.messageQueue.shift();
      this.socket.send(JSON.stringify(message));
      console.log("Sent queued message:", message);
    }
  }

  scheduleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.log("Max reconnection attempts reached");
      return;
    }

    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);

    console.log(
      `Scheduling reconnect attempt ${this.reconnectAttempts} in ${delay}ms`,
    );

    setTimeout(() => {
      if (this.authToken && !this.isConnected) {
        this.connectWebSocket();
      }
    }, delay);
  }

  disconnect() {
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
    this.isConnected = false;
  }

  notifyPopup(message) {
    // Send message to popup if it's open
    chrome.runtime.sendMessage(message).catch(() => {
      // Popup might not be open, that's okay
    });
  }

  setupMessageListeners() {
    chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
      switch (message.type) {
        case "authenticate":
          this.saveAuthData(message.token, message.user).then(() => {
            this.connectWebSocket();
            sendResponse({ success: true });
          });
          return true; // Indicate async response

        case "logout":
          this.clearAuthData();
          sendResponse({ success: true });
          break;

        case "send_message":
          this.sendMessage({
            event: "new_message",
            payload: message.payload,
          });
          sendResponse({ success: true });
          break;

        case "get_connection_status":
          sendResponse({
            connected: this.isConnected,
            user: this.currentUser,
          });
          break;

        default:
          console.log("Unknown message type:", message.type);
      }
    });
  }
}

// Initialize the background service
const chatBackground = new ChatExtensionBackground();

// Keep service worker alive
chrome.runtime.onStartup.addListener(() => {
  console.log("Extension startup - reinitializing background");
  chatBackground.init();
});
