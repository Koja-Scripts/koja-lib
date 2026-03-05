export interface ProgressBarData {
  label: string;
  description: string;
  duration: number;
  theme?: string;
  bottomOffset?: number;
}

export interface ProgressBarState {
  isVisible: boolean;
  data: ProgressBarData | null;
  progress: number;
  timeRemaining: number;
  isAnimating: boolean;
}
