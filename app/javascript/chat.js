// Function to initialize chat functionality
function initializeChat() {
  console.log("Initializing chat...");
  
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
        if (messagesArea) {
          messagesArea.innerHTML = '';
          if (messages.length === 0) {
            messagesArea.innerHTML = '<div class="empty-chat-note">No messages yet. Start the conversation!</div>';
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
              messagesArea.appendChild(messageDiv);
            });
            messagesArea.scrollTop = messagesArea.scrollHeight;
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
    // Remove existing listeners to avoid duplicates
    const newUserListContainer = userListContainer.cloneNode(true);
    userListContainer.parentNode.replaceChild(newUserListContainer, userListContainer);
    
    newUserListContainer.addEventListener('click', function(e) {
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
    if (!currentUserId) {
      console.error('No user selected');
      alert('Please select a user to chat with');
      return;
    }
    
    const content = messageInput.value.trim();
    if (!content) return;
    
    console.log("Sending message to user:", currentUserId, "Content:", content);
    
    fetch(`/chat/${currentUserId}/send_message`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({ message: { content: content } })
    })
    .then(response => response.json())
    .then(data => {
      console.log("Send response:", data);
      if (data.success) {
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message-bubble sent';
        messageDiv.innerHTML = `
          ${content}
          <div class="message-time">
            just now
            <i class="fas fa-check message-status"></i>
          </div>
        `;
        
        const emptyState = messagesArea.querySelector('.empty-chat-note');
        if (emptyState) emptyState.remove();
        
        messagesArea.appendChild(messageDiv);
        messagesArea.scrollTop = messagesArea.scrollHeight;
        messageInput.value = '';
      } else if (data.errors) {
        alert(data.errors.join(', '));
      }
    })
    .catch(error => {
      console.error('Error sending message:', error);
    });
  }
  
  // Send message on button click
  if (sendButton) {
    // Remove existing listeners
    const newSendButton = sendButton.cloneNode(true);
    sendButton.parentNode.replaceChild(newSendButton, sendButton);
    
    newSendButton.addEventListener('click', sendMessage);
  }
  
  // Send message on Enter key
  if (messageInput) {
    const newMessageInput = messageInput.cloneNode(true);
    messageInput.parentNode.replaceChild(newMessageInput, messageInput);
    
    newMessageInput.addEventListener('keypress', function(e) {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
      }
    });
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

// For Turbolinks (Rails 5-6), also initialize on turbolinks:load
document.addEventListener('turbolinks:load', initializeChat);