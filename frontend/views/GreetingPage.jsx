import React, { useState } from "react"
import { Box, Typography, Button, TextField } from "@mui/material"
import { starter } from "canisters/starter"
import LogoSquare from "/frontend/assets/logo_square.svg"

function GreetingPageView() {
  const [inputStr, SetInputStr] = useState("")
  const [hello, setHello] = useState("")
  async function doGreet() {
    if (inputStr !== "") {
      setHello("Greeting in progress...")
      let greeting = await starter.greet(inputStr)
      console.log(greeting)
      setHello(greeting)
    }
  }
  return (
    <Box
      margin="6rem 0 0 0"
      display="flex"
      flexDirection="column"
      alignItems="center"
    >
      <img
        src={LogoSquare}
        style={{ height: "20vmin", display: "block", margin: "2rem 0" }}
        alt="logo"
      />
      <Typography variant="h4">Greetings from Internet Computer</Typography>
      <TextField
        label="Greeting"
        variant="outlined"
        value={inputStr}
        placeholder="Enter a greeting"
        onChange={(e) => SetInputStr(e.target.value)}
        sx={{ margin: "2rem 0" }}
      />
      <Button
        variant="contained"
        color="primary"
        onClick={doGreet}
        sx={{ margin: "2rem 0" }}
      >
        send greeting
      </Button>
      <Typography variant="body1" color="secondary">
        {hello}
      </Typography>
    </Box>
  )
}

export default GreetingPageView
