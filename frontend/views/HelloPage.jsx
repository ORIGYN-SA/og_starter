import React, { useState } from "react"
import { Box, Typography, Button } from "@mui/material"
import { starter } from "canisters/starter"
import LogoSquare from "/frontend/assets/logo_square.svg"

function HelloPageView() {
  const [helloWorld, setHelloWorld] = useState("")

  async function queryHelloWorld() {
    setHelloWorld("Query is in progress...")
    let hello = await starter.hello()
    setHelloWorld(hello)
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
      <Typography variant="h4">Hello World from Internet Computer</Typography>
      <Button
        variant="contained"
        color="primary"
        children="query hello world"
        onClick={queryHelloWorld}
        sx={{ margin: "2rem 0" }}
      />
      <Typography
        sx={{ margin: "2rem 0" }}
        color="secondary"
        variant="body1"
        children={helloWorld}
      />
    </Box>
  )
}

export default HelloPageView
