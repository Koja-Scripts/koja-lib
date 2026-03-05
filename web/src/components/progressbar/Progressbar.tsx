import React, { useEffect, useRef } from "react";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "@/stores/store";
import { updateProgress, hideProgressBar, resetProgressBar } from "@/slices/progressBarSlice";
import { getTheme } from "@/types/themes";

const Progressbar: React.FC = () => {
  const dispatch = useDispatch();
  const progressBarState = useSelector((state: RootState) => state.progressBar);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  
  const theme = getTheme(progressBarState.data?.theme || "orange");
  const bottomOffset = progressBarState.data?.bottomOffset || 1;

  const keyframesStyle = `
    @keyframes slideUp {
      0% {
        opacity: 0;
        transform: translateX(-50%) translateY(3vw) scale(0.8) rotateX(-10deg);
      }
      60% {
        opacity: 1;
        transform: translateX(-50%) translateY(-0.2vw) scale(1.02) rotateX(2deg);
      }
      100% {
        opacity: 1;
        transform: translateX(-50%) translateY(0) scale(1) rotateX(0deg);
      }
    }
    
    @keyframes slideDown {
      0% {
        opacity: 1;
        transform: translateX(-50%) translateY(0) scale(1) rotateX(0deg);
      }
      40% {
        opacity: 1;
        transform: translateX(-50%) translateY(0.3vw) scale(0.98) rotateX(-5deg);
      }
      100% {
        opacity: 0;
        transform: translateX(-50%) translateY(2vw) scale(0.85) rotateX(-15deg);
      }
    }
  `;

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  useEffect(() => {
    if (progressBarState.isVisible && progressBarState.data && progressBarState.isAnimating) {
      const startTime = Date.now();
      const duration = progressBarState.data.duration * 1000;

      if (intervalRef.current) clearInterval(intervalRef.current);
      if (timeoutRef.current) clearTimeout(timeoutRef.current);

      intervalRef.current = setInterval(() => {
        const elapsed = Date.now() - startTime;
        const progress = Math.min((elapsed / duration) * 100, 100);
        const timeRemaining = Math.max(progressBarState.data!.duration - (elapsed / 1000), 0);

        dispatch(updateProgress({ progress, timeRemaining }));

        if (progress >= 100) {
          clearInterval(intervalRef.current!);
        }
      }, 100);

      timeoutRef.current = setTimeout(() => {
        dispatch(hideProgressBar());
        
        setTimeout(() => {
          dispatch(resetProgressBar());
        }, 500);
      }, duration);
    }

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, [progressBarState.isVisible, progressBarState.data, progressBarState.isAnimating, dispatch]);

  if (!progressBarState.isVisible || !progressBarState.data) {
    return null;
  }

  return (
    <>
      <style dangerouslySetInnerHTML={{ __html: keyframesStyle }} />
      <div 
        className={`min-w-[16.5vw] px-[.8vw] w-fit max-w-[20vw] min-h-[4vw] h-fit py-[.5vw] overflow-hidden rounded-[.7vw] absolute flex flex-col items-center justify-center left-1/2 -translate-x-1/2 gap-[.3vw] transition-all duration-700 ease-[cubic-bezier(0.34,1.56,0.64,1)]`}
        style={{
          animation: progressBarState.isAnimating 
            ? 'slideUp 0.7s cubic-bezier(0.34, 1.56, 0.64, 1) forwards' 
            : 'slideDown 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards',
          backfaceVisibility: 'hidden',
          bottom: `${bottomOffset}vw`,
          backgroundColor: theme.colors.background,
        }}
      >
        <div 
          className="w-[15vw] h-[15vw] blur-[19vw] opacity-30 absolute right-[-8vw] top-0"
          style={{ backgroundColor: theme.colors.backgroundGlow }}
        ></div>
        <div 
          className="w-[15vw] h-[15vw] blur-[19vw] opacity-15 absolute left-[-8vw] top-0"
          style={{ backgroundColor: theme.colors.backgroundGlow }}
        ></div>
    
        <div className="w-full h-fit flex items-center justify-between gap-[.6vw] z-[2]">
            <div className="flex flex-col">
                <span className="text-white font-semibold text-[.8vw]">
                  {progressBarState.data.label}
                </span>
                <span className="text-white/80 text-[.65vw] leading-[.7vw]">
                  {progressBarState.data.description}
                </span>
            </div>
            <div 
              className="w-fit h-[1.5vw] flex items-center text-[.7vw] px-[.4vw] rounded-[.2vw]"
              style={{ 
                color: theme.colors.primary,
                backgroundColor: theme.colors.primaryLight,
              }}
            >
                {formatTime(progressBarState.timeRemaining)}
            </div>
        </div>
        <div 
          className="w-full h-[.2vw] rounded-[.2vw] overflow-hidden"
          style={{ backgroundColor: theme.colors.primaryDark }}
        >
            <div 
              className="h-full transition-all duration-100 ease-linear"
              style={{ 
                width: `${progressBarState.progress}%`,
                backgroundColor: theme.colors.primary,
              }}
            ></div>
        </div>
      </div>
    </>
  );
};

export default Progressbar;
