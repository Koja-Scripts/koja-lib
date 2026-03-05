import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import type { ProgressBarData, ProgressBarState } from '@/types/progressBar';

const initialState: ProgressBarState = {
  isVisible: false,
  data: null,
  progress: 0,
  timeRemaining: 0,
  isAnimating: false
};

const progressBarSlice = createSlice({
  name: 'progressBar',
  initialState,
  reducers: {
    startProgressBar: (state, action: PayloadAction<ProgressBarData>) => {
      state.isVisible = true;
      state.data = action.payload;
      state.progress = 0;
      state.timeRemaining = action.payload.duration;
      state.isAnimating = true;
    },
    updateProgress: (state, action: PayloadAction<{ progress: number; timeRemaining: number }>) => {
      state.progress = action.payload.progress;
      state.timeRemaining = action.payload.timeRemaining;
    },
    hideProgressBar: (state) => {
      state.isAnimating = false;
    },
    resetProgressBar: (state) => {
      state.isVisible = false;
      state.data = null;
      state.progress = 0;
      state.timeRemaining = 0;
      state.isAnimating = false;
    }
  }
});

export const {
  startProgressBar,
  updateProgress,
  hideProgressBar,
  resetProgressBar
} = progressBarSlice.actions;

export default progressBarSlice.reducer;
