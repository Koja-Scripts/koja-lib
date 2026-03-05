import React from "react";
import ReactDOM from "react-dom/client";
import App from "./components/App";
import "./index.css";
import { isEnvBrowser } from './utils/misc';
import { Provider } from 'react-redux';
import { store } from './stores/store';
import LocaleProvider from './providers/LocaleProvider';

const rootElement = document.getElementById("root");
if (rootElement) {
	ReactDOM.createRoot(rootElement).render(
		<React.StrictMode>
			<Provider store={store}>
            	<LocaleProvider>
					<App />
				</LocaleProvider>
			</Provider>
		</React.StrictMode>
	);
}

if (isEnvBrowser()) {
    const root = document.getElementById('root');

    root!.style.backgroundImage = 'url("https://mir-s3-cdn-cf.behance.net/project_modules/1400/56451c209074139.66f9b82def289.png")';
    root!.style.backgroundSize = 'cover';
    root!.style.backgroundRepeat = 'no-repeat';
    root!.style.backgroundPosition = 'center';
}