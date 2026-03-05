import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface TextUIData {
  key: string;
  label: string;
  description: string;
  theme?: string;
  bottomOffset?: number;
}

interface TextUIState {
  isVisible: boolean;
  data: TextUIData | null;
  isAnimating: boolean;
}

const initialState: TextUIState = {
  isVisible: false,
  data: null,
  isAnimating: false
};

const textUISlice = createSlice({
  name: 'textUI',
  initialState,
  reducers: {
    startTextUI: (state, action: PayloadAction<TextUIData>) => {
      state.isVisible = true;
      state.data = action.payload;
      state.isAnimating = true;
    },
    closeTextUI: (state) => {
      state.isAnimating = false;
    },
    resetTextUI: (state) => {
      state.isVisible = false;
      state.data = null;
      state.isAnimating = false;
    }
  }
});

export const {
  startTextUI,
  closeTextUI,
  resetTextUI
} = textUISlice.actions;

export default textUISlice.reducer;
