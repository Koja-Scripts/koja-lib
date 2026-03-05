import React, { useEffect, useState } from "react";
import { useSelector, useDispatch } from "react-redux";
import { RootState } from "@/stores/store";
import { resetTextUI } from "@/slices/textUISlice";
import { getTheme } from "@/types/themes";

const TextUI: React.FC = () => {
  const dispatch = useDispatch();
  const { isVisible, data, isAnimating } = useSelector((state: RootState) => state.textUI);
  const [shouldShow, setShouldShow] = useState(false);
  
  const theme = getTheme(data?.theme || "orange");
  const bottomOffset = data?.bottomOffset || 5.5;

  useEffect(() => {
    if (isVisible && isAnimating) {
      const showTimer = setTimeout(() => {
        setShouldShow(true);
      }, 50);
      
      return () => clearTimeout(showTimer);
    } else if (!isAnimating && shouldShow) {
      setShouldShow(false);
      const hideTimer = setTimeout(() => {
        dispatch(resetTextUI());
      }, 500);
      
      return () => clearTimeout(hideTimer);
    } else if (!isVisible) {
      setShouldShow(false);
    }
  }, [isVisible, isAnimating, shouldShow, dispatch]);

  if (!isVisible || !data) return null;

  return (
    <div 
      className={`px-[.8vw] w-fit max-w-[20vw] min-h-[3.5vw] h-fit overflow-hidden rounded-[.7vw] absolute flex flex-col items-center justify-center left-1/2 -translate-x-1/2 gap-[.3vw] transform-gpu transition-all duration-500 ease-in-out ${
        shouldShow ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-2'
      }`}
      style={{
        bottom: `${bottomOffset}vw`,
        backgroundColor: theme.colors.background.replace('rgb', 'rgba').replace(')', ', 0.85)'),
      }}
    >
        <div className="w-full h-fit flex items-center gap-[.6vw] z-[2]">
            <div 
              className="w-[1.5vw] h-[1.5vw] flex items-center justify-center text-[.8vw] font-medium text-white rounded-[.2vw]"
              style={{ backgroundColor: theme.colors.primaryLight }}
            >
                {data.key}
            </div>
            <div className="flex flex-col justify-center leading-[.9vw]">
                <span className="text-white font-semibold text-[.75vw]">{data.label}</span>
                <span className="text-white/80 text-[.65vw]">{data.description}</span>
            </div>
        </div>
    </div>
  );
};

export default TextUI;
