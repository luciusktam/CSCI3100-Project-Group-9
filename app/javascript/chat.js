function initializeChat() {
  
  function scrollMessagesToBottom() {
    const messagesArea = document.getElementById('messagesArea');
    if (messagesArea) {
      messagesArea.scrollTop = messagesArea.scrollHeight;
    }
  }
  
  // Initialize notification manager
  if (!window.notificationManager) {
    window.notificationManager = new ChatNotificationManager();
  }

  // Get DOM elements
  const chatPlaceholder = document.getElementById('chatPlaceholder');
  const activeChatView = document.getElementById('activeChatView');
  const activeUserName = document.getElementById('activeUserName');
  const activeAvatar = document.getElementById('activeAvatar');
  const messageInput = document.getElementById('messageInput');
  const sendButton = document.getElementById('sendMessageBtn');
  const searchInput = document.getElementById('searchUsers');

  let currentUserId = null;
  let isLoadingConversation = false;
  let lastLoadedConversation = null;

  function loadConversation(userId, username) {
    if (isLoadingConversation || lastLoadedConversation === userId) return;

    isLoadingConversation = true;
    lastLoadedConversation = userId;
    currentUserId = userId;
    window.currentUserId = userId;

    if (activeUserName) activeUserName.textContent = username;
    if (activeAvatar) activeAvatar.textContent = username.charAt(0).toUpperCase();

    if (chatPlaceholder) chatPlaceholder.style.display = 'none';
    if (activeChatView) activeChatView.style.display = 'flex';

    // Show loading state
    const messagesArea = document.getElementById('messagesArea');
    if (messagesArea) {
      messagesArea.innerHTML = '<div class="loading-messages">Loading messages...</div>';
    }

    fetch(`/chat/${userId}/messages.json`)
      .then(response => response.json())
      .then(messages => {
        const messagesArea = document.getElementById('messagesArea');
        if (messagesArea) {
          messagesArea.innerHTML = '';

          if (messages.length === 0) {
            messagesArea.innerHTML = '<div class="empty-chat-note">No messages yet. Start the conversation!</div>';
          } else {
            messages.forEach(message => {
              const messageDiv = document.createElement('div');
              messageDiv.className = `message-bubble ${message.is_current_user ? 'sent' : 'received'}`;
              messageDiv.innerHTML = `
                ${escapeHtml(message.content)}
                <div class="message-time">
                  ${message.time_ago} ago
                  ${message.is_current_user ? '<i class="fas fa-check message-status"></i>' : ''}
                </div>
              `;
              messagesArea.appendChild(messageDiv);
            });
          scrollMessagesToBottom();
          }
        }

        // Clear badge
        if (window.notificationManager) {
          const userIdStr = userId.toString();
          window.notificationManager.unreadCount[userIdStr] = 0;
          window.notificationManager.updateHeaderChatButton();
          window.notificationManager.updateSidebarBadges();
        }
      })
      .catch(error => {
        console.error('Error fetching messages:', error);
      })
      .finally(() => {
        isLoadingConversation = false;
      });

    // Set active class
    document.querySelectorAll('.user-item').forEach(item => {
      item.classList.remove('active');
      if (parseInt(item.dataset.userId) === userId) {
        item.classList.add('active');
      }
    });
  }

  // Simple escape function
  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  function sendMessage() {
    const input = document.getElementById('messageInput');
    const content = input?.value.trim();
    if (!content || !currentUserId) return;

    const csrfToken = document.querySelector('[name="csrf-token"]')?.content;
    if (!csrfToken) return;

    // Clear input immediately
    input.value = '';

    // Auto-scroll immediately
    scrollMessagesToBottom();

    fetch(`/chat/${currentUserId}/send_message`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({ message: { content: content } })
    })
    .then(response => response.json())
    .then(data => {
      if (!data.success) {
        console.error('Send failed:', data.errors);
      }
    })
    .catch(error => {
      console.error('Error sending message:', error);
    });
  }

  // Clean listener attachment (NO cloning)
  const sendBtn = document.getElementById('sendMessageBtn');
  if (sendBtn) {
    sendBtn.addEventListener('click', sendMessage);
  }

  const msgInput = document.getElementById('messageInput');
  if (msgInput) {
    msgInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
      }
    });
  }

  // Attach send button and Enter key (without aggressive cloning)
  if (sendButton) {
    sendButton.addEventListener('click', sendMessage);
  }

  if (messageInput) {
    messageInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
      }
    });
  }

  // Search (simple version)
  if (searchInput) {
    searchInput.addEventListener('input', () => {
      const term = searchInput.value.toLowerCase();
      document.querySelectorAll('.user-item').forEach(item => {
        const username = item.dataset.username.toLowerCase();
        item.style.display = username.includes(term) ? 'flex' : 'none';
      });
    });
  }

  // Initialize unread counts
  function initializeUnreadCounts() {
    if (!window.notificationManager) return;
    const userItems = document.querySelectorAll('.user-item');
    userItems.forEach(item => {
      const badge = item.querySelector('.unread-badge');
      const userId = item.dataset.userId;
      if (badge && badge.textContent && userId) {
        const count = parseInt(badge.textContent);
        if (!isNaN(count)) {
          window.notificationManager.unreadCount[userId] = count;
        }
      }
    });
    window.notificationManager.updateHeaderChatButton();
  }

  setTimeout(initializeUnreadCounts, 100);

  // Handle direct URL access
  const pathParts = window.location.pathname.split('/');
  if (pathParts[1] === 'chat' && pathParts[2]) {
    const userId = parseInt(pathParts[2]);
    const userItem = document.querySelector(`.user-item[data-user-id="${userId}"]`);
    if (userItem) {
      loadConversation(userId, userItem.dataset.username);
    }
  }
}

// Initialize
document.addEventListener('DOMContentLoaded', initializeChat);
document.addEventListener('turbo:load', initializeChat);
document.addEventListener('turbo:before-stream-render', (event) => {
  // Only handle appends to the messages area
  if (event.target.action !== 'append' || event.target.target !== 'messagesArea') {
    return;
  }

  const template = event.target.querySelector('template');
  if (!template) return;

  const newBubble = template.content.querySelector('.message-bubble');
  if (!newBubble || !newBubble.dataset.senderId) return;

  const senderId = parseInt(newBubble.dataset.senderId);
  const currentUserId = window.currentUserId;   // already set by loadConversation()

  if (senderId === currentUserId) {
    newBubble.classList.add('received');
    newBubble.classList.remove('sent');
  } else {
    newBubble.classList.add('sent');
    newBubble.classList.remove('received');

    // Remove checkmark for the receiver
    const statusIcon = newBubble.querySelector('.message-status');
    if (statusIcon) statusIcon.remove();
  }

  // Scroll after the new message is appended
  setTimeout(() => {
    scrollMessagesToBottom();
  }, 30);
});