// Authentication utilities

export const getAuthToken = () => {
  return localStorage.getItem('authToken')
}

export const getUser = () => {
  const userData = localStorage.getItem('user')
  return userData ? JSON.parse(userData) : null
}

export const isAuthenticated = () => {
  const token = getAuthToken()
  const user = getUser()
  return !!(token && user)
}

export const logout = () => {
  localStorage.removeItem('authToken')
  localStorage.removeItem('user')
}

export const getAuthHeaders = () => {
  const token = getAuthToken()
  return token ? {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  } : {
    'Content-Type': 'application/json'
  }
}

// Helper function for authenticated API calls
export const authenticatedFetch = async (url, options = {}) => {
  const headers = {
    ...getAuthHeaders(),
    ...options.headers
  }

  const response = await fetch(url, {
    ...options,
    headers
  })

  // If unauthorized, redirect to login
  if (response.status === 401) {
    logout()
    window.location.href = '/login'
    return null
  }

  return response
}