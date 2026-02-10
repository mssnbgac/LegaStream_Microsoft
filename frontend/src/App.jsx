import React, { useEffect } from 'react'
import { Routes, Route } from 'react-router-dom'
import { Layout } from './components/Layout'
import { ProtectedRoute } from './components/ProtectedRoute'
import { Dashboard } from './pages/Dashboard'
import { DocumentUpload } from './pages/DocumentUpload'
import { LiveTerminal } from './pages/LiveTerminal'
import { Login } from './pages/Login'
import { Register } from './pages/Register'
import { ForgotPassword } from './pages/ForgotPassword'
import { ResetPassword } from './pages/ResetPassword'
import { ConfirmEmail } from './pages/ConfirmEmail'
import { Settings } from './pages/Settings'

function App() {
  // Apply saved theme on app load
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') || 'dark'
    const root = document.documentElement
    
    if (savedTheme === 'light') {
      root.classList.remove('dark')
      root.classList.add('light')
    } else if (savedTheme === 'dark') {
      root.classList.remove('light')
      root.classList.add('dark')
    } else if (savedTheme === 'system') {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      root.classList.remove('light', 'dark')
      root.classList.add(prefersDark ? 'dark' : 'light')
    }
    
    // Apply saved font size
    const savedFontSize = localStorage.getItem('fontSize') || 'medium'
    const sizeMap = {
      'small': '14px',
      'medium': '16px',
      'large': '18px',
      'extra-large': '20px'
    }
    root.style.fontSize = sizeMap[savedFontSize] || '16px'
  }, [])

  return (
    <div className="min-h-screen bg-gray-900 dark:bg-gray-900 light:bg-gray-50">
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/reset-password" element={<ResetPassword />} />
        <Route path="/confirm-email" element={<ConfirmEmail />} />
        <Route path="/" element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }>
          <Route index element={<Dashboard />} />
          <Route path="documents" element={<DocumentUpload />} />
          <Route path="terminal" element={<LiveTerminal />} />
          <Route path="settings" element={<Settings />} />
        </Route>
      </Routes>
    </div>
  )
}

export default App