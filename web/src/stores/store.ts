import { configureStore } from '@reduxjs/toolkit';
import progressBarReducer from '../slices/progressBarSlice';
import textUIReducer from '../slices/textUISlice';
import notificationReducer from '../slices/notificationSlice';

export const store = configureStore({
  reducer: {
    progressBar: progressBarReducer,
    textUI: textUIReducer,
    notification: notificationReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
