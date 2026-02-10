import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { isAuthenticated } from '../utils/auth'

export function ProtectedRoute({ children }) {
  const navigate = useNavigate()

  useEffect(() => {
    if (!isAuthenticated()) {
      navigate('/login', { replace: true })
    }
  }, [navigate])

  // If not authenticated, don't render anything (will redirect)
  if (!isAuthenticated()) {
    return null
  }

  return children
}