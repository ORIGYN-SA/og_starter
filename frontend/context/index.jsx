import React from "react"
import { createContext } from "react"
import useLocalStorage from "../hooks/useLocalStorage"

// SiteContext contains theme and drawer state

const initialState = {
  themeMode: "dark",
  drawerMode: false,
  onChangeMode: () => {},
  onDrawerMode: () => {},
}

const SiteContext = createContext(initialState)

function SiteProvider({ children }) {
  const [site, setSite] = useLocalStorage("site", {
    themeMode: initialState.themeMode,
  })

  const onChangeMode = (t) => {
    setSite({
      ...site,
      themeMode: t,
      drawerMode: false,
    })
  }
  const onDrawerMode = (d) => {
    setSite({
      ...site,
      drawerMode: d,
    })
  }

  return (
    <SiteContext.Provider
      value={{
        ...site,
        onChangeMode,
        onDrawerMode,
      }}
    >
      {children}
    </SiteContext.Provider>
  )
}

export { SiteProvider, SiteContext }
