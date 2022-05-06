import React from "react"
import {
  Box,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Divider,
} from "@mui/material"
import { Link } from "react-router-dom"
import HomeRounded from "@mui/icons-material/HomeRounded"
import HelloIcon from "@mui/icons-material/EmojiPeopleRounded"
import GreetingIcon from "@mui/icons-material/EmojiEmotionsRounded"
import CounterIcon from "@mui/icons-material/ControlPoint"
import LightIcon from "@mui/icons-material/Brightness7Rounded"
import DarkIcon from "@mui/icons-material/Brightness4Rounded"
import CallIcon from "@mui/icons-material/Call"
import useSite from "../../hooks/useSite"
// import {
//   ConnectButton,
//   ConnectDialog,
//   // Connect2ICProvider,
//   // useConnect,
// } from "@connect2ic/react"

const Items = [
  {
    page: "home",
    title: "HOME",
    icon: <HomeRounded />,
  },
  {
    page: "hello",
    title: "HELLO",
    icon: <HelloIcon />,
  },
  {
    page: "greeting",
    title: "GREETING",
    icon: <GreetingIcon />,
  },
  {
    page: "counter",
    title: "COUNTER",
    icon: <CounterIcon />,
  },
  {
    page: "inter-call",
    title: "INTER CALL",
    icon: <CallIcon />,
  },
]

function MenuList() {
  const { themeMode, onChangeMode } = useSite()
  const toggleTheme = () => {
    let t = themeMode === "light" ? "dark" : "light"
    onChangeMode(t)
  }
  return (
    <Box>
      <List>
        {Items.map((i) => (
          <ListItem
            button
            component={Link}
            to={i.page === "home" ? "/" : `/${i.page}`}
            key={i.page}
          >
            <ListItemIcon sx={{ pading: "8px" }}>{i.icon}</ListItemIcon>
            <ListItemText primary={i.title} />
          </ListItem>
        ))}
      </List>

      <Divider />
      <List>
        <ListItem button onClick={toggleTheme}>
          <ListItemIcon sx={{ pl: { xs: 0, sm: 1 } }}>
            {themeMode === "light" ? <DarkIcon /> : <LightIcon />}
          </ListItemIcon>
          <ListItemText primary={"THEME"} />
        </ListItem>
      </List>
      {/* <List>
        <ConnectButton />
        <ConnectDialog dark={false} />
      </List> */}
    </Box>
  )
}

export default MenuList
