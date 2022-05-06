import React, { useState, useCallback, useEffect } from "react"
import { Box, Typography, Button, LinearProgress } from "@mui/material"
import { starter } from "canisters/starter"
import LogoSquare from "/frontend/assets/logo_square.svg"

function CounterPageView() {
  const [count, setCount] = useState()

  const [isDisabled, setIsDisabled] = useState(false)

  async function refreshCounter() {
    const res = await starter.getValue()
    setCount(res.toString())
    setIsDisabled(false)
  }

  useEffect(() => {
    refreshCounter()
  }, [])

  const onIncrementClick = useCallback(async () => {
    setIsDisabled(true)
    setCount("...")
    await starter.increment()
    refreshCounter()
  }, [starter])
  return (
    <Box
      margin="6rem 0 0 0"
      display="flex"
      flexDirection="column"
      alignItems="center"
    >
      <img
        src={LogoSquare}
        style={{ height: "20vmin", display: "block", margin: "2rem 0 2rem 0" }}
        alt="logo"
      />
      <Typography variant="h4" gutterBottom>
        Counter from Internet Computer
      </Typography>
      <Box
        width="10%"
        margin="1rem 0"
        display={isDisabled === true ? "block" : "none"}
      >
        <LinearProgress style={{ margin: "1rem 0" }} />
        <LinearProgress color="secondary" />
      </Box>
      <Button
        variant="contained"
        color="primary"
        onClick={onIncrementClick}
        disabled={isDisabled}
        style={{
          display: isDisabled === true ? "none" : "block",
          margin: "2rem 0",
        }}
      >
        {`count is : ${count}`}
      </Button>
    </Box>
  )
}

export default CounterPageView
