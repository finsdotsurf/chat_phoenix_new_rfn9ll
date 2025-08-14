// Dark Chat Extension Popup Script
// Handles UI interactions, authentication, and real-time messaging

class ChatExtensionPopup {
  constructor() {
    this.isConnected = false;
    this.currentUser = null;
    this.authToken = null;
    this.messages = [];

    // DOM elements
    this.elements = {
      authSection: null,
      chatSection: null,
      loading: null,
      emailInput: null,
      passwordInput: null,
      loginBtn: null,
      authError: null,
      messageInput: null,
      sendBtn: null,
      messagesList: null,
      statusIndicator: null,
      settingsBtn: null,
    };

    this.init();
  }

  async init() {
    console.log("Dark Chat Extension popup initialized");

    // Cache DOM elements
    this.cacheDOMElements();

    // Set up event listeners
    this.setupEventListeners();

    // Check connection status with background
    await this.checkConnectionStatus();

    // Set up background message listener
    this.setupBackgroundListener();

    // Load any stored messages
    await this.loadStoredMessages();
  }

  cacheDOMElements() {
    this.elements.authSection = document.getElementById("authSection");
    this.elements.chatSection = document.getElementById("chatSection");
    this.elements.loading = document.getElementById("loading");
    this.elements.emailInput = document.getElementById("emailInput");
    this.elements.passwordInput = document.getElementById("passwordInput");
    this.elements.loginBtn = document.getElementById("loginBtn");
    this.elements.authError = document.getElementById("authError");
    this.elements.messageInput = document.getElementById("messageInput");
    this.elements.sendBtn = document.getElementById("sendBtn");
    this.elements.messagesList = document.getElementById("messagesList");
    this.elements.statusIndicator = document.getElementById("status");
    this.elements.settingsBtn = document.getElementById("settingsBtn");
  }

  setupEventListeners() {
    // Authentication form
    this.elements.loginBtn.addEventListener("click", () => this.handleLogin());
    this.elements.passwordInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter") this.handleLogin();
    });

    // Message sending
    this.elements.sendBtn.addEventListener("click", () => this.sendMessage());
    this.elements.messageInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        this.sendMessage();
      }
    });

    // Settings button
    this.elements.settingsBtn.addEventListener("click", () =>
      this.showSettings(),
    );
  }

  async checkConnectionStatus() {
    try {
      const response = await chrome.runtime.sendMessage({
        type: "get_connection_status",
      });

      this.isConnected = response.connected;
      this.currentUser = response.user;

      if (this.currentUser) {
        this.showChatInterface();
      } else {
        this.showAuthInterface();
      }

      this.updateConnectionStatus();
    } catch (error) {
      console.error("Failed to check connection status:", error);
      this.showAuthInterface();
    }
  }

  setupBackgroundListener() {
    chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
      switch (message.type) {
        case "new_message":
          this.addMessage(message.message);
          break;
        case "connection_status":
          this.isConnected = message.connected;
          this.updateConnectionStatus();
          break;
        case "connection_error":
          this.showError(`Connection error: ${message.error}`);
          break;
        case "user_joined":
          this.showSystemMessage(`${message.user.username} joined the chat`);
          break;
        case "user_left":
          this.showSystemMessage(`${message.user.username} left the chat`);
          break;
      }
    });
  }

  async handleLogin() {
    const email = this.elements.emailInput.value.trim();
    const password = this.elements.passwordInput.value;

    if (!email || !password) {
      this.showError("Please enter both email and password");
      return;
    }

    this.showLoading("Signing in...");

    try {
      // Authenticate with Phoenix backend
      const response = await fetch("http://localhost:4000/api/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email,
          password: password,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        // Store auth data and connect
        await chrome.runtime.sendMessage({
          type: "authenticate",
          token: data.token,
          user: data.user,
        });

        this.currentUser = data.user;
        this.authToken = data.token;
        this.showChatInterface();
        this.hideError();
      } else {
        this.showError(data.error || "Login failed");
      }
    } catch (error) {
      console.error("Login error:", error);
      this.showError(
        "Connection failed. Please check if the chat app is running.",
      );
    } finally {
      this.hideLoading();
    }
  }

  async sendMessage() {
    const content = this.elements.messageInput.value.trim();
    if (!content) return;

    // Clear input immediately for better UX
    this.elements.messageInput.value = "";

    try {
      // Send through background script
      await chrome.runtime.sendMessage({
        type: "send_message",
        payload: {
          content: content,
          user_id: this.currentUser.id,
        },
      });

      // Add message to UI optimistically
      this.addMessage({
        content: content,
        user: this.currentUser,
        timestamp: new Date().toISOString(),
        id: Date.now(), // Temporary ID
      });
    } catch (error) {
      console.error("Failed to send message:", error);
      this.showError("Failed to send message");
      // Restore message content on error
      this.elements.messageInput.value = content;
    }
  }

  addMessage(message) {
    const messageEl = document.createElement("div");
    messageEl.className = `message ${
      message.user.id === this.currentUser?.id ? "own" : "other"
    }`;

    const contentEl = document.createElement("div");
    contentEl.className = "message-content";
    contentEl.textContent = message.content;

    const metaEl = document.createElement("div");
    metaEl.className = "message-meta";
    const time = new Date(message.timestamp).toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
    });
    metaEl.textContent = `${message.user.username} • ${time}`;

    messageEl.appendChild(contentEl);
    messageEl.appendChild(metaEl);

    this.elements.messagesList.appendChild(messageEl);
    this.scrollToBottom();

    // Store message
    this.messages.push(message);
    this.storeMessages();
  }

  showSystemMessage(text) {
    const messageEl = document.createElement("div");
    messageEl.className = "message system";
    messageEl.textContent = text;
    this.elements.messagesList.appendChild(messageEl);
    this.scrollToBottom();
  }

  scrollToBottom() {
    const container = this.elements.messagesList.parentElement;
    container.scrollTop = container.scrollHeight;
  }

  showAuthInterface() {
    this.elements.authSection.style.display = "flex";
    this.elements.chatSection.style.display = "none";
    this.elements.loading.style.display = "none";
  }

  showChatInterface() {
    this.elements.authSection.style.display = "none";
    this.elements.chatSection.style.display = "flex";
    this.elements.loading.style.display = "none";
    this.elements.messageInput.focus();
  }

  showLoading(text) {
    this.elements.loading.style.display = "flex";
    this.elements.loading.querySelector("p").textContent = text;
    this.elements.authSection.style.display = "none";
    this.elements.chatSection.style.display = "none";
  }

  hideLoading() {
    this.elements.loading.style.display = "none";
  }

  showError(message) {
    this.elements.authError.textContent = message;
    this.elements.authError.style.display = "block";
  }

  hideError() {
    this.elements.authError.style.display = "none";
  }

  updateConnectionStatus() {
    if (this.isConnected) {
      this.elements.statusIndicator.classList.add("connected");
      this.elements.statusIndicator.title = "Connected to chat";
    } else {
      this.elements.statusIndicator.classList.remove("connected");
      this.elements.statusIndicator.title = "Disconnected";
    }
  }

  async showSettings() {
    const confirmed = confirm("Sign out from Dark Chat?");
    if (confirmed) {
      await chrome.runtime.sendMessage({ type: "logout" });
      this.currentUser = null;
      this.authToken = null;
      this.messages = [];
      this.elements.messagesList.innerHTML = "";
      this.showAuthInterface();
    }
  }

  async loadStoredMessages() {
    try {
      const result = await chrome.storage.local.get(["recentMessages"]);
      if (result.recentMessages) {
        this.messages = result.recentMessages;
        this.messages.forEach((message) => this.addMessage(message));
      }
    } catch (error) {
      console.error("Failed to load stored messages:", error);
    }
  }

  async storeMessages() {
    try {
      // Keep only last 50 messages
      const recentMessages = this.messages.slice(-50);
      await chrome.storage.local.set({ recentMessages });
    } catch (error) {
      console.error("Failed to store messages:", error);
    }
  }
}

// Initialize popup when DOM is ready
document.addEventListener("DOMContentLoaded", () => {
  new ChatExtensionPopup();
});
