import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { NotificationData, Notification, NotificationState } from '@/types/notification';

const initialState: NotificationState = {
  notifications: [],
  maxNotifications: 5
};

const notificationSlice = createSlice({
  name: 'notification',
  initialState,
  reducers: {
    createNotification: (state, action: PayloadAction<NotificationData>) => {
      const newNotification = action.payload;

      const stackKey = `${newNotification.label}-${newNotification.tag || ''}-${newNotification.type}-${newNotification.description}`;
      
      const existingIndex = state.notifications.findIndex(notif => {
        const existingKey = `${notif.label}-${notif.tag || ''}-${notif.type}-${notif.description}`;
        return existingKey === stackKey;
      });
      
      if (existingIndex !== -1) {
        const existingNotif = state.notifications[existingIndex];
        existingNotif.count += 1;
        existingNotif.timestamp = Date.now();
        existingNotif.duration = newNotification.duration;
        existingNotif.isRemoving = false;
      } else {
        const notification: Notification = {
          ...newNotification,
          id: `${Date.now()}-${Math.random()}`,
          timestamp: Date.now(),
          count: 1,
          isRemoving: false
        };
        
        state.notifications.unshift(notification);
        
        if (state.notifications.length > state.maxNotifications) {
          state.notifications = state.notifications.slice(0, state.maxNotifications);
        }
      }
    },
    
    startNotificationExit: (state, action: PayloadAction<string>) => {
      const notification = state.notifications.find(notif => notif.id === action.payload);
      if (notification) {
        notification.isRemoving = true;
      }
    },
    
    removeNotification: (state, action: PayloadAction<string>) => {
      state.notifications = state.notifications.filter(notif => notif.id !== action.payload);
    },
    
    clearAllNotifications: (state) => {
      state.notifications = [];
    }
  }
});

export const {
  createNotification,
  startNotificationExit,
  removeNotification,
  clearAllNotifications
} = notificationSlice.actions;

export default notificationSlice.reducer;
