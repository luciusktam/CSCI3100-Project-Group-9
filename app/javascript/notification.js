// app/assets/javascripts/notification.js
class ChatNotificationManager {
  constructor() {
    this.notifications = [];
    this.unreadCount = {};
    this.initHeaderChatButton();
    this.loadUnreadCountsFromServer();
  }

  initHeaderChatButton() {
    // Find the chat button using your specific ID
    this.headerChatButton = document.getElementById('navChatLink');
    this.navBadge = document.getElementById('chatNavBadge');
    
    console.log('🔔 Notification Manager Initialized');
    console.log('Header chat button found:', this.headerChatButton);
    console.log('Nav badge found:', this.navBadge);
  }

  async loadUnreadCountsFromServer() {
    try {
      console.log('Loading unread counts from server...');
      const response = await fetch('/chat/unread_counts.json');
      const data = await response.json();
      this.unreadCount = data.unread_counts || {};
      console.log('Loaded unread counts:', this.unreadCount);
      this.updateHeaderChatButton();
    } catch (error) {
      console.error('Error loading unread counts:', error);
    }
  }

  incrementUnreadCount(userId) {
    this.unreadCount[userId] = (this.unreadCount[userId] || 0) + 1;
    console.log(`Incremented unread count for user ${userId}: ${this.unreadCount[userId]}`);
    this.updateHeaderChatButton();
    this.updatePageTitle();
  }

  clearUnreadCount(userId) {
    this.unreadCount[userId] = 0;
    console.log(`Cleared unread count for user ${userId}`);
    this.updateHeaderChatButton();
    this.updatePageTitle();
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
      console.log('✅ Badge updated to show:', this.navBadge.textContent);
    } else {
      this.navBadge.style.display = 'none';
      this.navBadge.style.animation = '';
      console.log('❌ Badge hidden - no unread messages');
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
  console.log('🔄 Turbo loaded, re-initializing notification manager...');
  if (!window.notificationManager) {
    window.notificationManager = new ChatNotificationManager();
  } else {
    window.notificationManager.initHeaderChatButton();
    window.notificationManager.loadUnreadCountsFromServer();
  }
});