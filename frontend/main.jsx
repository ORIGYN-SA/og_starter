import React from "react"
import ReactDOM from "react-dom"
import { SiteProvider } from "./context"
import { HashRouter } from "react-router-dom"
import { defaultProviders } from "@connect2ic/core/providers"
import { Connect2ICProvider } from "@connect2ic/react"
// Styles for the ConnectDialog & Button
// import "@connect2ic/core/style.css"
import * as starter from "canisters/starter"

import App from "./App"

ReactDOM.render(
  <React.StrictMode>
    <Connect2ICProvider
      canisters={{
        starter,
      }}
      providers={defaultProviders}
      // host={host}
    >
      <SiteProvider>
        <HashRouter>
          <App />
        </HashRouter>
      </SiteProvider>
    </Connect2ICProvider>
  </React.StrictMode>,
  document.getElementById("root"),
)
