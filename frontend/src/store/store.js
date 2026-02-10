import { configureStore } from '@reduxjs/toolkit'

// Simple store for now - will expand as we add features
export const store = configureStore({
  reducer: {
    // Add reducers here as we build features
    auth: (state = { user: null, token: null }, action) => {
      switch (action.type) {
        case 'LOGIN_SUCCESS':
          return { ...state, user: action.payload.user, token: action.payload.token }
        case 'LOGOUT':
          return { user: null, token: null }
        default:
          return state
      }
    }
  },
})