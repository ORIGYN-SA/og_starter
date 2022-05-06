import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
// material
import { styled } from '@mui/material/styles';
import { Box, Button, Typography, Container } from '@mui/material';
// import PageNotFoundIllustration from '../assets/illustration_404'

const RootStyle = styled(Box)(({ theme }) => ({
  display: 'flex',
  minHeight: '100%',
  alignItems: 'center',
  paddingTop: theme.spacing(15),
  paddingBottom: theme.spacing(10),
}));

// ----------------------------------------------------------------------

export default function Page404() {
  return (
    <RootStyle>
      <Container>
        <Box sx={{ maxWidth: 480, margin: 'auto', textAlign: 'center' }}>
          <Box>
            <Typography variant="h3" paragraph>
              Sorry, page not found
            </Typography>
          </Box>
          <Typography sx={{ color: 'text.secondary' }}>
            We couldn’t find the page you’re looking for. Perhaps you’ve
            mistyped the URL? Be sure to check your spelling.
          </Typography>

          <Box>
            {/* <PageNotFoundIllustration
              sx={{ height: 260, my: { xs: 5, sm: 10 } }}
            /> */}
          </Box>

          <Button
            to="/"
            size="large"
            variant="contained"
            component={RouterLink}
          >
            Go to Home
          </Button>
        </Box>
      </Container>
    </RootStyle>
  );
}
