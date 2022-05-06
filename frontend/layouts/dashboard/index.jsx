import React from "react"
import { Outlet } from "react-router-dom"
import { Hidden, Box } from "@mui/material"
import DashSidebar from "./DashSidebar"
import DashNavbar from "./DashNavbar"
import {
  ConnectButton,
  ConnectDialog,
  // Connect2ICProvider,
  // useConnect,
} from "@connect2ic/react"

export default function DashboardLayout() {
  return (
    <Box
      sx={{
        display: "flex",
        // minHeight: '100%',
        // overflow: 'hidden',
        // backgroundColor: "#00ff",
        // height: '100vh',
      }}
    >
      <Hidden lgUp>
        <DashNavbar />
      </Hidden>
      <Hidden lgDown>
        <DashSidebar />
      </Hidden>
      <Box
        sx={{
          marginTop: "100px",
          flexGrow: "1",
          padding: (theme) => theme.spacing(3),
          width: "calc(100% - 320px)",
        }}
      >
        <Outlet />
      </Box>
      <ConnectDialog />
    </Box>
  )
}
