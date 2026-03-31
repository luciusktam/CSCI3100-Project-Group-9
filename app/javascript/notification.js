class ChatNotificationManager {
  constructor() {
    this.notifications = [];
    this.unreadCount = {};
    this.processingClick = false;
    this.initHeaderChatButton();
    this.loadUnreadCountsFromServer();
    this.setupConversationClickListener();
  }

  initHeaderChatButton() {
    // Find the chat button using your specific ID
    this.headerChatButton = document.getElementById('navChatLink');
    this.navBadge = document.getElementById('chatNavBadge');
  }

  setupConversationClickListener() {
    // Listen for clicks on conversation links in the sidebar
    document.addEventListener('click', (event) => {
      z

      // Find the closest user-item link that was clicked
      const userItem = event.target.closest('.user-item');
      
      if (userItem && userItem.dataset.userId) {
        const userId = parseInt(userItem.dataset.userId);
        const currentUnreadForUser = this.unreadCount[userId] || 0;
        
        if (currentUnreadForUser > 0) {
          this.processingClick = true;
          
          // Clear the unread count
          this.clearUnreadCount(userId);
        }
      }
    });
  }

  updateSidebarBadge(userId, hasUnread) {
    const userItem = document.querySelector(`.user-item[data-user-id="${userId}"]`);
    if (userItem) {
      const badge = userItem.querySelector('.unread-badge');
      if (!hasUnread && badge) {
        badge.style.display = 'none';
        badge.textContent = '';
      }
    }
  }

  async loadUnreadCountsFromServer() {
    try {
      const response = await fetch('/chat/unread_counts.json');
      const data = await response.json();
      this.unreadCount = data.unread_counts || {};
      this.updateHeaderChatButton();
      this.updateSidebarBadges();
    } catch (error) {
      console.error('Error loading unread counts:', error);
    }
  }

  updateSidebarBadges() {
    // Update all sidebar badges based on unread counts
    Object.keys(this.unreadCount).forEach(userId => {
      const count = this.unreadCount[userId];
      const userItem = document.querySelector(`.user-item[data-user-id="${userId}"]`);
      
      if (userItem && count > 0) {
        let badge = userItem.querySelector('.unread-badge');
        if (!badge) {
          const userNameDiv = userItem.querySelector('.user-name');
          if (userNameDiv) {
            badge = document.createElement('span');
            badge.className = 'unread-badge';
            userNameDiv.appendChild(badge);
          }
        }
        if (badge) {
          const displayCount = count > 99 ? '99+' : count;
          badge.textContent = displayCount;
          badge.style.display = 'inline-block';
        }
      } else if (userItem && count === 0) {
        const badge = userItem.querySelector('.unread-badge');
        if (badge) {
          badge.style.display = 'none';
          badge.textContent = '';
        }
      }
    });
  }

  incrementUnreadCount(userId) {
    this.unreadCount[userId] = (this.unreadCount[userId] || 0) + 1;
    this.updateHeaderChatButton();
    this.updatePageTitle();
    this.updateSidebarBadges();
  }

  clearUnreadCount(userId) {
    if (this.unreadCount[userId] && this.unreadCount[userId] > 0) {
      this.unreadCount[userId] = 0;
      this.updateHeaderChatButton();
      this.updatePageTitle();
      this.updateSidebarBadges();
      this.markMessagesAsRead(userId);
    }
  }

  async markMessagesAsRead(userId) {
    try {
      const csrfToken = document.querySelector('[name="csrf-token"]')?.content;
      if (!csrfToken) return;
      
      await fetch('/chat/update_unread_count', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ user_id: userId, count: 0 })
      });
    } catch (error) {
      console.error('Failed to mark messages as read:', error);
    }
  }

  updateHeaderChatButton() {
    if (!this.headerChatButton) {
      this.initHeaderChatButton();
    }
    
    if (!this.navBadge) {
      console.warn('⚠️ Nav badge element (chatNavBadge) not found');
      return;
    }
    
    // Calculate total unread count across all conversations
    const totalUnread = Object.values(this.unreadCount).reduce((a, b) => a + b, 0);
    console.log('Total unread messages:', totalUnread);
    
    if (totalUnread > 0) {
      this.navBadge.textContent = totalUnread > 99 ? '99+' : totalUnread;
      this.navBadge.style.display = 'inline-block';
      this.navBadge.style.animation = 'pulse 1.5s ease-in-out infinite';
    } else {
      this.navBadge.style.display = 'none';
      this.navBadge.style.animation = '';
    }
  }

  updatePageTitle() {
    const totalUnread = Object.values(this.unreadCount).reduce((a, b) => a + b, 0);
    const originalTitle = document.title.replace(/^\(\d+\)\s/, '');
    
    if (totalUnread > 0) {
      document.title = `(${totalUnread}) ${originalTitle}`;
    } else {
      document.title = originalTitle;
    }
  }
}

// Initialize on all pages
document.addEventListener('DOMContentLoaded', () => {
  console.log('🚀 DOM loaded, initializing notification manager...');
  window.notificationManager = new ChatNotificationManager();
});

// Also handle Turbo navigation if you're using Turbo
document.addEventListener('turbo:load', () => {
  if (!window.notificationManager) {
    window.notificationManager = new ChatNotificationManager();
  } else {
    window.notificationManager.initHeaderChatButton();
    window.notificationManager.loadUnreadCountsFromServer();
    window.notificationManager.setupConversationClickListener();
  }
});