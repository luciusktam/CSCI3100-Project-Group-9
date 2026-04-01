class ChatNotificationManager {
  constructor() {
    this.notifications = [];
    this.unreadCount = {};
    this.processingClick = false;
    this.isSettingUpListeners = false;
    this.pendingClicks = new Map(); // Track pending clicks per user
    this.clickLock = new Map(); // Lock per user to prevent concurrent updates
    this.debounceTimers = new Map(); // Debounce timers per user
    this.initHeaderChatButton();
    this.loadUnreadCountsFromServer();
    this.setupConversationClickListener();
  }

  initHeaderChatButton() {
    this.headerChatButton = document.getElementById('navChatLink');
    this.navBadge = document.getElementById('chatNavBadge');
  }

  setupConversationClickListener() {
    if (this.isSettingUpListeners) return;
    this.isSettingUpListeners = true;
    
    document.querySelectorAll('.user-item').forEach(item => {
      // Remove any existing listeners by cloning
      const newItem = item.cloneNode(true);
      item.parentNode.replaceChild(newItem, item);
      
      // Add debounced click handler
      newItem.addEventListener('click', (event) => {
        event.preventDefault();
        event.stopPropagation();
        
        const userId = parseInt(newItem.dataset.userId);
        const username = newItem.dataset.username;
        
        // Debounce the click to prevent rapid multiple clicks
        if (this.debounceTimers.has(userId)) {
          clearTimeout(this.debounceTimers.get(userId));
        }
        
        this.debounceTimers.set(userId, setTimeout(() => {
          this.handleUserClick(userId, username);
        }, 100));
      });
    });
  }
  
  async handleUserClick(userId, username) {
    // Prevent multiple simultaneous clicks for the same user
    if (this.clickLock.get(userId)) {
      console.log(`Click for user ${userId} is locked, skipping`);
      return;
    }
    
    // Check if we're already processing this click
    if (this.pendingClicks.get(userId)) {
      console.log(`Click for user ${userId} already pending, skipping`);
      return;
    }
    
    // Lock this user
    this.clickLock.set(userId, true);
    this.pendingClicks.set(userId, true);
    
    try {
      const currentUnreadForUser = this.unreadCount[userId] || 0;
      console.log(`User clicked: ${userId}, unread count: ${currentUnreadForUser}`);
      
      // Only clear if there are unread messages
      if (currentUnreadForUser > 0) {
        console.log(`Clearing unread count for user ${userId}`);
        this.processingClick = true;
        
        // Clear the unread count immediately in UI
        const previousCount = this.unreadCount[userId];
        this.unreadCount[userId] = 0;
        this.updateHeaderChatButton();
        this.updateSidebarBadges();
        
        // Mark as read on server (async, don't wait)
        this.markMessagesAsRead(userId).catch(error => {
          console.error('Failed to mark messages as read:', error);
          // If server update fails, restore the count
          if (previousCount > 0 && this.unreadCount[userId] === 0) {
            this.unreadCount[userId] = previousCount;
            this.updateHeaderChatButton();
            this.updateSidebarBadges();
          }
        });
      }
      
      // Navigate to the chat page
      window.location.href = `/chat/${userId}`;
      
    } catch (error) {
      console.error('Error handling user click:', error);
    } finally {
      // Unlock after a short delay to allow navigation to complete
      setTimeout(() => {
        this.clickLock.delete(userId);
        this.pendingClicks.delete(userId);
        this.processingClick = false;
      }, 500);
    }
  }

  async loadUnreadCountsFromServer() {
    try {
      console.log('Loading unread counts from server...');
      const response = await fetch('/chat/unread_counts.json');
      const data = await response.json();
      
      // Only update if the counts have changed
      const newUnreadCount = data.unread_counts || {};
      let hasChanges = false;
      
      // Check for changes
      const allUserIds = new Set([...Object.keys(this.unreadCount), ...Object.keys(newUnreadCount)]);
      for (const userId of allUserIds) {
        const oldCount = this.unreadCount[userId] || 0;
        const newCount = newUnreadCount[userId] || 0;
        if (oldCount !== newCount) {
          hasChanges = true;
          break;
        }
      }
      
      if (hasChanges) {
        console.log('Unread counts changed, updating:', newUnreadCount);
        this.unreadCount = newUnreadCount;
        this.updateHeaderChatButton();
        this.updateSidebarBadges();
        this.updatePageTitle();
      } else {
        console.log('No changes in unread counts');
      }
    } catch (error) {
      console.error('Error loading unread counts:', error);
    }
  }

  updateSidebarBadges() {
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
          // Add a data attribute to track the count
          badge.setAttribute('data-count', count);
        }
      } else if (userItem && count === 0) {
        const badge = userItem.querySelector('.unread-badge');
        if (badge && badge.style.display !== 'none') {
          badge.style.display = 'none';
          badge.textContent = '';
          badge.removeAttribute('data-count');
        }
      }
    });
  }

  incrementUnreadCount(userId) {
    // Don't increment if this user is currently being clicked
    if (this.clickLock.get(userId)) {
      console.log(`Not incrementing unread for user ${userId} - click in progress`);
      return;
    }
    
    const newCount = (this.unreadCount[userId] || 0) + 1;
    this.unreadCount[userId] = newCount;
    this.updateHeaderChatButton();
    this.updatePageTitle();
    this.updateSidebarBadges();
  }

  clearUnreadCount(userId) {
    // Don't clear if already processing this user
    if (this.clickLock.get(userId)) {
      console.log(`Not clearing unread for user ${userId} - click in progress`);
      return;
    }
    
    if (this.unreadCount[userId] && this.unreadCount[userId] > 0) {
      const oldCount = this.unreadCount[userId];
      console.log(`Clearing unread count for user ${userId}: ${oldCount} -> 0`);
      this.unreadCount[userId] = 0;
      this.updateHeaderChatButton();
      this.updatePageTitle();
      this.updateSidebarBadges();
      
      // Only call server if there were actually unread messages
      if (oldCount > 0) {
        this.markMessagesAsRead(userId);
      }
    }
  }

  async markMessagesAsRead(userId) {
    // Prevent multiple mark as read requests for the same user
    if (this.pendingClicks.get(`mark_read_${userId}`)) {
      console.log(`Already marking messages as read for user ${userId}, skipping`);
      return;
    }
    
    this.pendingClicks.set(`mark_read_${userId}`, true);
    
    try {
      const csrfToken = document.querySelector('[name="csrf-token"]')?.content;
      if (!csrfToken) return;
      
      console.log(`Marking messages as read for user ${userId}`);
      const response = await fetch('/chat/update_unread_count', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ user_id: userId })
      });
      
      const data = await response.json();
      console.log(`Marked as read response:`, data);
      
    } catch (error) {
      console.error('Failed to mark messages as read:', error);
      throw error; // Re-throw to allow caller to handle
    } finally {
      setTimeout(() => {
        this.pendingClicks.delete(`mark_read_${userId}`);
      }, 1000);
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
    
    const totalUnread = Object.values(this.unreadCount).reduce((a, b) => a + b, 0);
    console.log('Total unread messages:', totalUnread);
    
    if (totalUnread > 0) {
      const displayCount = totalUnread > 99 ? '99+' : totalUnread;
      this.navBadge.textContent = displayCount;
      this.navBadge.style.display = 'inline-block';
      this.navBadge.style.animation = 'pulse 1.5s ease-in-out infinite';
      
      // Add a data attribute to track the total
      this.navBadge.setAttribute('data-total', totalUnread);
    } else {
      this.navBadge.style.display = 'none';
      this.navBadge.style.animation = '';
      this.navBadge.removeAttribute('data-total');
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

// Initialize on all pages with safety check
let initializationComplete = false;

function initializeNotificationManager() {
  if (initializationComplete) {
    console.log('Notification manager already initialized');
    return;
  }
  
  console.log('🚀 Initializing notification manager...');
  
  if (!window.notificationManager) {
    window.notificationManager = new ChatNotificationManager();
    initializationComplete = true;
  } else {
    console.log('Notification manager already exists, refreshing...');
    window.notificationManager.initHeaderChatButton();
    window.notificationManager.loadUnreadCountsFromServer();
    window.notificationManager.setupConversationClickListener();
  }
}

// Initialize on all pages
document.addEventListener('DOMContentLoaded', initializeNotificationManager);
document.addEventListener('turbo:load', () => {
  // Reset initialization flag for Turbo navigation
  initializationComplete = false;
  initializeNotificationManager();
});

// Also handle page visibility changes to refresh counts
document.addEventListener('visibilitychange', () => {
  if (!document.hidden && window.notificationManager) {
    console.log('Page became visible, refreshing unread counts');
    window.notificationManager.loadUnreadCountsFromServer();
  }
});