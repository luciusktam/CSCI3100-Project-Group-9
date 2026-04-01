function initializeChat() {
  // Initialize notification manager
  if (!window.notificationManager) {
    window.notificationManager = new ChatNotificationManager();
  }
  
  // Request desktop notification permission on user interaction
  const requestPermissionBtn = document.getElementById('enableNotifications');
  if (requestPermissionBtn) {
    requestPermissionBtn.addEventListener('click', () => {
      window.notificationManager.requestDesktopPermission();
    });
  }
  
  // Get DOM elements
  const userListContainer = document.getElementById('userListContainer');
  const chatPlaceholder = document.getElementById('chatPlaceholder');
  const activeChatView = document.getElementById('activeChatView');
  const messagesArea = document.getElementById('messagesArea');
  const messageInput = document.getElementById('messageInput');
  const sendButton = document.getElementById('sendMessageBtn');
  const activeUserName = document.getElementById('activeUserName');
  const activeAvatar = document.getElementById('activeAvatar');
  const searchInput = document.getElementById('searchUsers');
  
  let currentUserId = null;
  let isLoadingConversation = false;
  let lastLoadedConversation = null;
  
  function loadConversation(userId, username) {
    if (lastLoadedConversation === userId && isLoadingConversation === false) {
      return;
    }

    if (isLoadingConversation) {
      return;
    }
    
    isLoadingConversation = true;
    lastLoadedConversation = userId;
    currentUserId = userId;
    window.currentUserId = userId;
    
    if (activeUserName) activeUserName.textContent = username;
    if (activeAvatar) activeAvatar.textContent = username.charAt(0).toUpperCase();
    
    if (chatPlaceholder) chatPlaceholder.style.display = 'none';
    if (activeChatView) activeChatView.style.display = 'flex';
    
    const currentMessagesArea = document.getElementById('messagesArea');
    if (currentMessagesArea) {
      currentMessagesArea.innerHTML = '<div class="loading-messages">Loading messages...</div>';
    }

    fetch(`/chat/${userId}/messages.json`)
      .then(response => response.json())
      .then(messages => {
        const currentMessagesArea = document.getElementById('messagesArea');
        if (currentMessagesArea) {
          currentMessagesArea.innerHTML = '';
          if (messages.length === 0) {
            currentMessagesArea.innerHTML = '<div class="empty-chat-note">No messages yet. Start the conversation!</div>';
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
              currentMessagesArea.appendChild(messageDiv);
            });
            currentMessagesArea.scrollTop = currentMessagesArea.scrollHeight;
          }
        }
      })
      .catch(error => {
        console.error('Error fetching messages:', error);
      });
    
    document.querySelectorAll('.user-item').forEach(item => {
      item.classList.remove('active');
      if (item.dataset.userId == userId) {
        item.classList.add('active');
      }
    });
  }
  
  // Escape HTML helper
  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
  
  // Check if we're on a specific chat URL
  const pathParts = window.location.pathname.split('/');
  
  if (pathParts[1] === 'chat' && pathParts[2]) {
    const userId = parseInt(pathParts[2]);
    
    const userItem = document.querySelector(`.user-item[data-user-id="${userId}"]`);
    if (userItem) {
      const username = userItem.dataset.username;
      loadConversation(userId, username);
    } else {
      fetch(`/users/${userId}.json`)
        .then(response => response.json())
        .then(user => {
          loadConversation(userId, user.username);
        })
        .catch(error => {
          console.error('Error fetching user:', error);
        });
    }
  }
  
  let isSendingMessage = false;
  // Send message function
  function sendMessage() {
    if (isSendingMessage) {
      return;
    }
    if (!currentUserId) {
      console.error('No user selected');
      alert('Please select a user to chat with');
      return;
    }
    
    const currentMessageInput = document.getElementById('messageInput');
    if (!currentMessageInput) {
      console.error('Message input not found');
      return;
    }
    
    const content = currentMessageInput.value.trim();
    
    if (!content) {
      return;
    }
    
    const csrfToken = document.querySelector('[name="csrf-token"]');
    if (!csrfToken) {
      console.error('CSRF token not found');
      return;
    }
    
    fetch(`/chat/${currentUserId}/send_message`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken.content,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({ message: { content: content } })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      if (data.success) {
        const currentMessagesArea = document.getElementById('messagesArea');
        if (!currentMessagesArea) {
          console.error('Messages area not found');
          return;
        }
        
        // Remove empty state if present
        const emptyState = currentMessagesArea.querySelector('.empty-chat-note');
        if (emptyState) emptyState.remove();
        
        // Add new message
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message-bubble sent';
        messageDiv.innerHTML = `
          ${escapeHtml(content)}
          <div class="message-time">
            just now
            <i class="fas fa-check message-status"></i>
          </div>
        `;
        currentMessagesArea.appendChild(messageDiv);
        currentMessagesArea.scrollTop = currentMessagesArea.scrollHeight;
        
        // Clear input
        const currentMessageInput = document.getElementById('messageInput');
        if (currentMessageInput) currentMessageInput.value = '';
      } else if (data.errors) {
        alert(data.errors.join(', '));
      }
    })
    .catch(error => {
      console.error('Error sending message:', error);
      alert('Failed to send message. Check console for details.');
    });
  }
  
  // Send message on button click
  if (sendButton) {
    const newSendButton = sendButton.cloneNode(true);
    sendButton.parentNode.replaceChild(newSendButton, sendButton);
    newSendButton.addEventListener('click', function(e) {
      sendMessage();
    });
  } else {
    console.error("Send button not found!");
  }
  
  // Send message on Enter key
  const messageInputElement = document.getElementById('messageInput');
  if (messageInputElement) {
    const newMessageInput = messageInputElement.cloneNode(true);
    messageInputElement.parentNode.replaceChild(newMessageInput, messageInputElement);
    
    newMessageInput.addEventListener('keypress', function(e) {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
      }
    });
  } else {
    console.error("Message input not found!");
  }
  
  // Search functionality
  if (searchInput) {
    const newSearchInput = searchInput.cloneNode(true);
    searchInput.parentNode.replaceChild(newSearchInput, searchInput);
    
    newSearchInput.addEventListener('input', function() {
      const searchTerm = this.value.toLowerCase();
      const userItems = document.querySelectorAll('.user-item');
      
      userItems.forEach(item => {
        const username = item.dataset.username.toLowerCase();
        if (username.includes(searchTerm)) {
          item.style.display = 'flex';
        } else {
          item.style.display = 'none';
        }
      });
    });
  }
  
  // Initialize unread counts from server-side badges
  function initializeUnreadCounts() {
    const userItems = document.querySelectorAll('.user-item');
    userItems.forEach(item => {
      const badge = item.querySelector('.unread-badge');
      if (badge && badge.textContent) {
        const userId = item.dataset.userId;
        const count = parseInt(badge.textContent);
        if (userId && !isNaN(count)) {
          window.notificationManager.unreadCount[userId] = count;
        }
      }
    });
    window.notificationManager.updateHeaderChatButton();
  }
  
  // Call after a short delay to ensure all elements are loaded
  setTimeout(initializeUnreadCounts, 100);
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', initializeChat);
document.addEventListener('turbo:load', initializeChat);