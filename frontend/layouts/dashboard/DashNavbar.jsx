import React from "react"
import { AppBar, Toolbar, Box } from "@mui/material"

import { alpha } from "@mui/system"
import MobileDrawer from "./MobileDrawer"
import {
  ConnectButton,
  ConnectDialog,
  // Connect2ICProvider,
  // useConnect,
} from "@connect2ic/react"

export default function DashNavbar() {
  return (
    <AppBar
      sx={{
        boxShadow: 0,
        padding: (theme) => theme.spacing(1),
        backgroundImage: "none",
        backdropFilter: "blur(6px)",
        WebkitBackdropFilter: "blur(6px)", // Fix on Mobile
        backgroundColor: (theme) =>
          alpha(theme.palette.background.default, 0.72),
      }}
    >
      <Toolbar>
        <MobileDrawer />
        <Box sx={{ marginLeft: "auto" }}>
          <ConnectButton />
        </Box>
      </Toolbar>
    </AppBar>
  )
}
