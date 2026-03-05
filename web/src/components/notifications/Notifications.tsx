import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '@/stores/store';
import { startNotificationExit, removeNotification } from '@/slices/notificationSlice';
import { Notification, NotificationType, NotificationPosition } from '@/types/notification';
import { CircleCheck, CircleAlert, CircleX, HelpCircle } from "lucide-react";

const hexToRgba = (hex: string, alpha: number) => {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
};

const NotificationIcon: React.FC<{ type: NotificationType; color?: string }> = ({ type, color }) => {
  const iconMap = {
    success: CircleCheck,
    warning: CircleAlert,
    error: CircleX,
    question: HelpCircle,
    info: HelpCircle
  };
  
  const Icon = iconMap[type] || HelpCircle;
  const hexColor = color || '#ffffff';

  return (
    <div 
      className="w-[2.2vw] h-[2.2vw] relative flex items-center justify-center border-[.1vw] rounded-[.3vw] outline-1 outline outline-white/40 outline-offset-[.15vw]"
      style={{
        backgroundColor: hexToRgba(hexColor, 0.1),
        borderColor: hexToRgba(hexColor, 0.3),
      }}
    >
      <Icon className="w-[1.1vw] h-[1.1vw] text-white" />
      <div 
        className="w-[.15vw] h-[1vw] absolute left-[-.3vw] rounded-full"
        style={{ backgroundColor: hexColor }}
      />
    </div>
  );
};

const NotificationItem: React.FC<{ notification: Notification }> = ({ notification }) => {
  const dispatch = useDispatch();
  const [isVisible, setIsVisible] = useState(false);
  
  const hexColor = notification.color || '#ffffff';
  
  useEffect(() => {
    const fadeInTimer = setTimeout(() => {
      setIsVisible(true);
    }, 50);
    
    return () => clearTimeout(fadeInTimer);
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => {
      dispatch(startNotificationExit(notification.id));
    }, notification.duration * 1000);
    
    return () => clearTimeout(timer);
  }, [notification.id, notification.duration, notification.timestamp, dispatch]);
  
  useEffect(() => {
    if (notification.isRemoving) {
      setIsVisible(false);
      const exitTimer = setTimeout(() => {
        dispatch(removeNotification(notification.id));
      }, 500);
      
      return () => clearTimeout(exitTimer);
    }
  }, [notification.isRemoving, notification.id, dispatch]);
  
  return (
    <div 
      className={`w-full min-h-[4vw] h-fit gap-[.4vw] px-[.8vw] rounded-[.25vw] flex items-center transform-gpu transition-all duration-500 ${
        isVisible && !notification.isRemoving 
          ? 'opacity-100 translate-y-0 scale-100' 
          : 'opacity-0 translate-y-[-1vw] scale-95'
      }`}
      style={{
        transitionTimingFunction: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)',
        backgroundColor: 'rgba(0, 0, 0, 0.7)',
      }}
    >
      <div className="min-w-[2.5vw] flex flex-col h-full rounded-[.5vw] gap-[.4vw]">
        <NotificationIcon type={notification.type} color={hexColor} />
      </div>
      <div className="w-full h-full flex flex-col">
        <div className="w-full flex items-center gap-[.3vw]">
          <span className="text-[.8vw] font-medium text-white leading-[1vw]">
            {notification.label}
          </span>
          {notification.tag && (
            <div 
              className="w-fit h-fit text-[.7vw] px-[.4vw] rounded-[.2vw]"
              style={{
                color: hexColor,
                backgroundColor: hexToRgba(hexColor, 0.15)
              }}
            >
              {notification.tag}
            </div>
          )}
          {notification.count > 1 && (
            <span className="text-[.6vw] px-[.3vw] bg-white/20 text-white rounded-[.2vw]">
              {notification.count}
            </span>
          )}
        </div>
        {notification.description && typeof notification.description === 'string' && (
          <div 
            className="text-[.65vw] font-light text-white/70 leading-[.9vw]"
            dangerouslySetInnerHTML={{ __html: notification.description }}
          />
        )}
      </div>
    </div>
  );
};

const Notifications: React.FC = () => {
  const { notifications } = useSelector((state: RootState) => state.notification);
  
  if (notifications.length === 0) return null;
  
  // Grupowanie notyfikacji według pozycji
  const notificationsByPosition = notifications.reduce((acc, notification) => {
    const position = notification.position || 'topright';
    if (!acc[position]) {
      acc[position] = [];
    }
    acc[position].push(notification);
    return acc;
  }, {} as Record<NotificationPosition, Notification[]>);
  
  // Definiowanie stylów dla każdej pozycji
  const positionStyles: Record<NotificationPosition, string> = {
    top: 'top-[1vw] left-1/2 -translate-x-1/2',
    topright: 'top-[1vw] right-[1vw]',
    topleft: 'top-[1vw] left-[1vw]',
    midright: 'top-1/2 -translate-y-1/2 right-[1vw]',
    midleft: 'top-1/2 -translate-y-1/2 left-[1vw]',
  };
  
  return (
    <>
      {Object.entries(notificationsByPosition).map(([position, notifs]) => (
        <div 
          key={position}
          className={`w-[16.5vw] h-fit absolute flex flex-col items-center justify-center gap-[.5vw] ${positionStyles[position as NotificationPosition]}`}
        >
          {notifs.map((notification) => (
            <NotificationItem key={notification.id} notification={notification} />
          ))}
        </div>
      ))}
    </>
  );
};

export default Notifications;
