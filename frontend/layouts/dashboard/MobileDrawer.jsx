import { Box, Divider, Drawer, IconButton } from "@mui/material"
import MenuIcon from "@mui/icons-material/Menu"
import React from "react"
import useSite from "../../hooks/useSite"
import MenuList from "../../components/menu"
import Logo from "/frontend/assets/logo.svg"

function MobileDrawer() {
  const { drawerMode, onDrawerMode } = useSite()

  const onClickClose = () => {
    onDrawerMode(false)
  }
  const onClickOpen = () => {
    onDrawerMode(true)
  }
  return (
    <Box display="flex" alignContent="center">
      <IconButton
        size="large"
        edge="start"
        sx={{ mr: 3 }}
        onClick={onClickOpen}
      >
        <MenuIcon fontSize="inherit" />
      </IconButton>

      <Drawer anchor="left" open={drawerMode} onClose={onClickClose}>
        <Box width="320px">
          <Box
            sx={{
              display: "flex",
              flexDirection: "column",
              padding: "1rem 2rem",
            }}
          >
            <img
              style={{
                marginBottom: ".5rem",
                cursor: "pointer",
                padding: "5px",
                borderRadius: "10px",
              }}
              alt="logo"
              src={Logo}
            />
          </Box>
          <Divider />
          <MenuList />
        </Box>
      </Drawer>
    </Box>
  )
}

export default MobileDrawer
