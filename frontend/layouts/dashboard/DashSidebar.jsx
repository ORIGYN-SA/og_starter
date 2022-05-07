import React from "react"
import {
  Box,
  Drawer,
  AppBar,
  Toolbar,
  Typography,
  Divider,
} from "@mui/material"
import Logo from "../../components/Logo"
import {
  ConnectButton,
  // ConnectDialog,
  // Connect2ICProvider,
  // useConnect,
} from "@connect2ic/react"

import { alpha } from "@mui/system"
import MenuList from "../../components/menu"

export default function DashSidebar() {
  return (
    <Box width="320px" bgcolor="red">
      <AppBar
        sx={{
          width: "calc(100% - 320px)",
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
          <Box sx={{ marginLeft: "auto" }}>
            <ConnectButton />
          </Box>
        </Toolbar>
      </AppBar>
      <Drawer variant="permanent" open={true}>
        <Box width="320px">
          <Box
            style={{
              display: "flex",
              flexDirection: "column",
              padding: "1rem 2rem",
            }}
          >
            {/* <img
              style={{
                marginBottom: ".5rem",
                cursor: "pointer",
                padding: "5px",
                borderRadius: "10px",
              }}
              alt="logo"
              src={Logo}
            /> */}
            <Box sx={{ padding: "8px" }}>
              <Logo />
            </Box>
          </Box>
          <Divider />
          <MenuList />
        </Box>
      </Drawer>
    </Box>
  )
}
