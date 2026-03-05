import { Context, createContext, useContext, useEffect, useState } from 'react';
import { useIsFirstRender } from '../hooks/isFirstRender';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import { isEnvBrowser } from '../utils/misc';

debugData([
    {
        action: 'setLocale',
        data: {
            ui: {
                decoding:{
                    title: "Decode the Morde code.",
                    clues: "Decoding Clues",
                    passwords: "Passwords Obtained",
                    enter_password: "Enter Password",
                    auto_decoding: "Auto-decoding in progress..."
                },
            }
        }
    },
]);

interface Locale {
    ui: {
        decoding:{
            title: string;
            clues: string;
            passwords: string;
            enter_password: string;
            auto_decoding: string;
        }
    },
    game: {

    }
}

interface LocaleContextValue {
    locale: Locale;
    setLocale: (locales: Locale) => void;
}

const LocaleCtx = createContext<LocaleContextValue | null>(null);

const LocaleProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const isFirst = useIsFirstRender();
    const [locale, setLocale] = useState<Locale>({
        ui: {
            decoding: {
                title: "Decode the Morde code.",
                clues: "Decoding Clues",
                passwords: "Passwords Obtained",
                enter_password: "Enter Password",
                auto_decoding: "Auto-decoding in progress..."
            }
        },
        game: {
            
        }
    });

    useEffect(() => {
        if (!isFirst && !isEnvBrowser()) return;
        fetchNui('loadLocale');
    }, []);

    useNuiEvent('setLocale', async (data: Locale) => setLocale(data));

    return <LocaleCtx.Provider value={{ locale, setLocale }}>{children}</LocaleCtx.Provider>;
};

export default LocaleProvider;

export const useLocales = () => useContext<LocaleContextValue>(LocaleCtx as Context<LocaleContextValue>);