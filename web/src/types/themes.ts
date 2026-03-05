export interface Theme {
  name: string;
  colors: {
    primary: string;
    primaryLight: string;
    primaryDark: string;
    background: string;
    backgroundGlow: string;
  };
}

export const themes: Record<string, Theme> = {
  orange: {
    name: "Pomarańczowy",
    colors: {
      primary: "rgb(249, 115, 22)",
      primaryLight: "rgba(249, 115, 22, 0.1)",
      primaryDark: "rgba(249, 115, 22, 0.15)",
      background: "rgb(0, 0, 0)",
      backgroundGlow: "rgb(249, 115, 22)",
    },
  },
  darkGray: {
    name: "Ciemny Szary",
    colors: {
      primary: "rgb(156, 163, 175)",
      primaryLight: "rgba(156, 163, 175, 0.1)",
      primaryDark: "rgba(156, 163, 175, 0.15)",
      background: "rgb(17, 24, 39)",
      backgroundGlow: "rgb(156, 163, 175)",
    },
  },
  darkBlack: {
    name: "Ciemny Czarny",
    colors: {
      primary: "rgb(209, 213, 219)",
      primaryLight: "rgba(209, 213, 219, 0.1)",
      primaryDark: "rgba(209, 213, 219, 0.15)",
      background: "rgb(0, 0, 0)",
      backgroundGlow: "rgb(75, 85, 99)",
    },
  },
  navy: {
    name: "Granatowy",
    colors: {
      primary: "rgb(59, 130, 246)",
      primaryLight: "rgba(59, 130, 246, 0.1)",
      primaryDark: "rgba(59, 130, 246, 0.15)",
      background: "rgb(15, 23, 42)",
      backgroundGlow: "rgb(59, 130, 246)",
    },
  },
  green: {
    name: "Zielony",
    colors: {
      primary: "rgb(34, 197, 94)",
      primaryLight: "rgba(34, 197, 94, 0.1)",
      primaryDark: "rgba(34, 197, 94, 0.15)",
      background: "rgb(5, 20, 10)",
      backgroundGlow: "rgb(34, 197, 94)",
    },
  },
  purple: {
    name: "Fioletowy",
    colors: {
      primary: "rgb(168, 85, 247)",
      primaryLight: "rgba(168, 85, 247, 0.1)",
      primaryDark: "rgba(168, 85, 247, 0.15)",
      background: "rgb(24, 10, 39)",
      backgroundGlow: "rgb(168, 85, 247)",
    },
  },
  red: {
    name: "Czerwony",
    colors: {
      primary: "rgb(239, 68, 68)",
      primaryLight: "rgba(239, 68, 68, 0.1)",
      primaryDark: "rgba(239, 68, 68, 0.15)",
      background: "rgb(30, 5, 5)",
      backgroundGlow: "rgb(239, 68, 68)",
    },
  },
};

export const getTheme = (themeName: string): Theme => {
  return themes[themeName] || themes.orange;
};
