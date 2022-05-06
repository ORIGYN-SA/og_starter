import React from "react"
import ThemeConfig from "./theme"
import Router from "./routes"

// const host = window.location.origin

function App() {
  return (
    <ThemeConfig>
      <Router />
    </ThemeConfig>
  )
}

export default App
