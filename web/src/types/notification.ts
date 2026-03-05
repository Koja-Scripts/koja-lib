export type NotificationType = 'success' | 'warning' | 'error' | 'question' | 'info';
export type NotificationPosition = 'top' | 'topright' | 'topleft' | 'midright' | 'midleft';

export interface NotificationData {
  label: string;
  tag?: string;
  description: string;
  color?: string;
  type: NotificationType;
  duration: number;
  position?: NotificationPosition;
}

export interface Notification extends NotificationData {
  id: string;
  timestamp: number;
  count: number;
  isRemoving?: boolean;
}

export interface NotificationState {
  notifications: Notification[];
  maxNotifications: number;
}
