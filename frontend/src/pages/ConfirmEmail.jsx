import { useState, useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { CheckCircle, XCircle, Loader2 } from 'lucide-react'

export function ConfirmEmail() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const [status, setStatus] = useState('confirming') // confirming, success, error
  const [message, setMessage] = useState('')
  const token = searchParams.get('token')

  useEffect(() => {
    const confirmEmail = async () => {
      if (!token) {
        setStatus('error')
        setMessage('Invalid confirmation link. No token provided.')
        return
      }

      try {
        const response = await fetch('/api/v1/auth/confirm_email', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ token }),
        })

        const data = await response.json()

        if (response.ok) {
          setStatus('success')
          setMessage(data.message || 'Email confirmed successfully!')
          
          // Redirect to login after 3 seconds
          setTimeout(() => {
            navigate('/login', { 
              state: { 
                message: 'Email confirmed! You can now log in.',
                email: data.user?.email 
              } 
            })
          }, 3000)
        } else {
          setStatus('error')
          setMessage(data.errors?.[0] || data.error || 'Email confirmation failed.')
        }
      } catch (error) {
        console.error('Confirmation error:', error)
        setStatus('error')
        setMessage('Failed to confirm email. Please try again or contact support.')
      }
    }

    confirmEmail()
  }, [token, navigate])

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        <div className="bg-gray-800 rounded-2xl shadow-2xl p-8 border border-gray-700">
          {/* Logo */}
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-2xl mb-4">
              <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" />
              </svg>
            </div>
            <h1 className="text-3xl font-bold text-white mb-2">Legal Auditor Agent</h1>
            <p className="text-gray-400">Email Confirmation</p>
          </div>

          {/* Status Display */}
          <div className="text-center">
            {status === 'confirming' && (
              <div className="space-y-4">
                <Loader2 className="w-16 h-16 text-blue-500 animate-spin mx-auto" />
                <h2 className="text-xl font-semibold text-white">Confirming your email...</h2>
                <p className="text-gray-400">Please wait while we verify your email address.</p>
              </div>
            )}

            {status === 'success' && (
              <div className="space-y-4">
                <CheckCircle className="w-16 h-16 text-green-500 mx-auto" />
                <h2 className="text-xl font-semibold text-white">Email Confirmed!</h2>
                <p className="text-gray-400">{message}</p>
                <div className="mt-6 p-4 bg-green-900/20 border border-green-800 rounded-lg">
                  <p className="text-sm text-green-400">
                    Redirecting to login page in 3 seconds...
                  </p>
                </div>
                <button
                  onClick={() => navigate('/login')}
                  className="mt-4 w-full bg-gradient-to-r from-blue-600 to-indigo-600 text-white py-3 px-4 rounded-lg font-medium hover:from-blue-700 hover:to-indigo-700 transition-all duration-200"
                >
                  Go to Login Now
                </button>
              </div>
            )}

            {status === 'error' && (
              <div className="space-y-4">
                <XCircle className="w-16 h-16 text-red-500 mx-auto" />
                <h2 className="text-xl font-semibold text-white">Confirmation Failed</h2>
                <p className="text-gray-400">{message}</p>
                <div className="mt-6 space-y-3">
                  <button
                    onClick={() => navigate('/login')}
                    className="w-full bg-gradient-to-r from-blue-600 to-indigo-600 text-white py-3 px-4 rounded-lg font-medium hover:from-blue-700 hover:to-indigo-700 transition-all duration-200"
                  >
                    Go to Login
                  </button>
                  <button
                    onClick={() => navigate('/register')}
                    className="w-full bg-gray-700 text-white py-3 px-4 rounded-lg font-medium hover:bg-gray-600 transition-all duration-200"
                  >
                    Register Again
                  </button>
                </div>
                <div className="mt-6 p-4 bg-yellow-900/20 border border-yellow-800 rounded-lg">
                  <p className="text-sm text-yellow-400">
                    If you continue to have issues, please contact support.
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Help Text */}
        <div className="mt-6 text-center">
          <p className="text-sm text-gray-400">
            Need help? Contact{' '}
            <a href="mailto:support@legalauditor.com" className="text-blue-400 hover:text-blue-300">
              support@legalauditor.com
            </a>
          </p>
        </div>
      </div>
    </div>
  )
}
