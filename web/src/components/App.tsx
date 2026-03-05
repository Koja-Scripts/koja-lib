import React from "react";
import { useDispatch } from "react-redux";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { startProgressBar, hideProgressBar, resetProgressBar } from "@/slices/progressBarSlice";
import { startTextUI, closeTextUI } from "@/slices/textUISlice";
import { createNotification } from "@/slices/notificationSlice";
import Progressbar from "./progressbar/Progressbar";
import TextUI from "./textui/TextUI";
import Notifications from "./notifications/Notifications";
import { debugData } from "../utils/debugData";
import type { ProgressBarData } from "@/types/progressBar";
import type { TextUIData } from "@/slices/textUISlice";
import type { NotificationData } from "@/types/notification";

debugData<any>([
  {
    action: "koja-lib:nui:startProgressBar",
    data: {
      label: "LECZENIE",
      description: "Trwa leczenie ran...",
      duration: 10,
    },
  }
]);

debugData<any>([
  {
    action: "koja-lib:nui:hideProgressBar",
    data: null
  }
]);

debugData<any>([
  {
    action: "koja-lib:nui:resetProgressBar",
    data: null
  }
]);

debugData<any>([
  {
    action: "koja-lib:nui:startTextUI",
    data: {
      key: "E",
      label: "Przeszukaj",
      description: "Naciśnij E aby przeszukać"
    }
  }
]);

debugData<any>([
  {
    action: "koja-lib:nui:createNotification",
    data: {
      label: "Test Powiadomienia",
      tag: "DEBUG",
      description: "To jest testowa notyfikacja",
      type: "success",
      duration: 5,
      position: "topright"
    }
  }
], 3000);

const App: React.FC = () => {
  const dispatch = useDispatch();

  useNuiEvent('koja-lib:nui:startProgressBar', (data: ProgressBarData) => {
    console.log(JSON.stringify(data));
    dispatch(startProgressBar(data));
  });

  useNuiEvent('koja-lib:nui:hideProgressBar', () => {
    dispatch(hideProgressBar());
    setTimeout(() => {
      dispatch(resetProgressBar());
    }, 500);
  });

  useNuiEvent('koja-lib:nui:resetProgressBar', () => {
    dispatch(resetProgressBar());
  });

  useNuiEvent('koja-lib:nui:startTextUI', (data: TextUIData) => {
    dispatch(startTextUI(data));
  });

  useNuiEvent('koja-lib:nui:closeTextUI', () => {
    dispatch(closeTextUI());
  });

  useNuiEvent('koja-lib:nui:createNotification', (data: NotificationData) => {
    dispatch(createNotification(data));
  });

  return (
    <div className="app dark overflow-hidden antialiased font-Geist flex items-center justify-center w-screen h-screen">
      <Progressbar />
      <TextUI />
      <Notifications />
    </div>
  );
};

export default App;
