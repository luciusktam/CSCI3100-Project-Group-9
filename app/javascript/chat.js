function initializeChat() {
  console.log("Initializing chat...");
  
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
  
  function loadConversation(userId, username) {
    console.log("Loading conversation for:", userId, username);
    currentUserId = userId;
    
    if (activeUserName) activeUserName.textContent = username;
    if (activeAvatar) activeAvatar.textContent = username.charAt(0).toUpperCase();
    
    if (chatPlaceholder) chatPlaceholder.style.display = 'none';
    if (activeChatView) activeChatView.style.display = 'flex';
    
    fetch(`/chat/${userId}/messages.json`)
      .then(response => response.json())
      .then(messages => {
        console.log("Messages received:", messages);
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
                ${message.content}
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
  
  // Check if we're on a specific chat URL
  const pathParts = window.location.pathname.split('/');
  console.log("Path parts:", pathParts);
  
  if (pathParts[1] === 'chat' && pathParts[2]) {
    const userId = parseInt(pathParts[2]);
    console.log("Found userId in URL:", userId);
    
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
  } else {
    console.log("No specific chat URL");
  }
  
  // Handle user clicks in sidebar
  if (userListContainer) {
    userListContainer.addEventListener('click', function(e) {
      const userItem = e.target.closest('.user-item');
      if (userItem) {
        const userId = userItem.dataset.userId;
        const username = userItem.dataset.username;
        console.log("Clicked user:", username, userId);
        window.location.href = `/chat/${userId}`;
      }
    });
  }
  
  // Send message function
  function sendMessage() {
    console.log("=== SEND MESSAGE CALLED ===");
    
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
    console.log("Content:", content);
    
    if (!content) {
      console.log("No content, returning");
      return;
    }
    
    const csrfToken = document.querySelector('[name="csrf-token"]');
    if (!csrfToken) {
      console.error('CSRF token not found');
      return;
    }
    
    console.log("Sending to URL:", `/chat/${currentUserId}/send_message`);
    
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
      console.log("Response status:", response.status);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      console.log("Response data:", data);
      if (data.success) {
        console.log("Message sent successfully");
        
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
          ${content}
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
        
        console.log("Message added to UI");
      } else if (data.errors) {
        console.log("Errors from server:", data.errors);
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
    console.log("Adding click listener to send button");
    // Remove any existing listeners by replacing the button
    const newSendButton = sendButton.cloneNode(true);
    sendButton.parentNode.replaceChild(newSendButton, sendButton);
    newSendButton.addEventListener('click', function(e) {
      console.log("Send button clicked!");
      sendMessage();
    });
  } else {
    console.error("Send button not found!");
  }
  
  // Send message on Enter key
  const messageInputElement = document.getElementById('messageInput');
  if (messageInputElement) {
    console.log("Adding keypress listener to message input");
    const newMessageInput = messageInputElement.cloneNode(true);
    messageInputElement.parentNode.replaceChild(newMessageInput, messageInputElement);
    
    newMessageInput.addEventListener('keypress', function(e) {
      console.log("Key pressed:", e.key);
      if (e.key === 'Enter' && !e.shiftKey) {
        console.log("Enter pressed, sending message");
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
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', initializeChat);

// For Turbo (Rails 7+), also initialize on turbo:load
document.addEventListener('turbo:load', initializeChat);