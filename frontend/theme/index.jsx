import React from "react"
import { useMemo } from "react"
import { CssBaseline } from "@mui/material"
import {
  createTheme,
  responsiveFontSizes,
  ThemeProvider,
  StyledEngineProvider,
} from "@mui/material/styles"
import palette from "./palette"
import useSite from "../hooks/useSite"

export default function ThemeConfig({ children }) {
  const { themeMode } = useSite()
  const isLight = themeMode === "light"

  const themeOptions = useMemo(
    () => ({
      palette: isLight
        ? { ...palette.light, mode: "light" }
        : { ...palette.dark, mode: "dark" },
      shape: {
        borderRadius: 8,
        borderRadiusSm: 12,
        borderRadiusMd: 16,
      },
      // Overrides
      components: {
        MuiPaper: {
          defaultProps: {
            elevation: 0,
          },
          styleOverrides: {
            root: {
              backgroundImage: "none",
            },
          },
        },
      },
    }),
    [isLight],
  )

  let theme = createTheme(themeOptions)
  theme = responsiveFontSizes(theme)

  return (
    <StyledEngineProvider injectFirst>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        {children}
      </ThemeProvider>
    </StyledEngineProvider>
  )
}
