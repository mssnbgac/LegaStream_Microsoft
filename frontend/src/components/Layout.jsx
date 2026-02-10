import { useState, useEffect, useRef } from 'react'
import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom'
import { 
  FileText, 
  Terminal, 
  BarChart3, 
  Settings, 
  Scale, 
  Bell, 
  Search, 
  User, 
  ChevronDown,
  Menu,
  X,
  Shield,
  Activity,
  LogOut,
  UserCircle,
  Cog,
  CheckCircle,
  AlertCircle,
  RefreshCw
} from 'lucide-react'
import { authenticatedFetch } from '../utils/auth'

export function Layout() {
  const location = useLocation()
  const navigate = useNavigate()
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [userMenuOpen, setUserMenuOpen] = useState(false)
  const [notificationsOpen, setNotificationsOpen] = useState(false)
  const [user, setUser] = useState(null)
  const [notifications, setNotifications] = useState([])
  const [isRefreshingNotifications, setIsRefreshingNotifications] = useState(false)
  const userMenuRef = useRef(null)
  const notificationsRef = useRef(null)

  // Load user data from localStorage
  useEffect(() => {
    const userData = localStorage.getItem('user')
    if (userData) {
      setUser(JSON.parse(userData))
    }
  }, [])

  // Fetch notifications
  useEffect(() => {
    fetchNotifications()
    // Refresh notifications every 10 seconds for more responsive updates
    const interval = setInterval(fetchNotifications, 10000)
    return () => clearInterval(interval)
  }, [])

  const fetchNotifications = async () => {
    try {
      setIsRefreshingNotifications(true)
      const response = await authenticatedFetch('/api/v1/documents')
      if (response && response.ok) {
        const data = await response.json()
        const docs = data.documents || []
        
        // Generate notifications from recent document activity
        const recentNotifications = docs
          .sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at))
          .slice(0, 5)
          .map(doc => {
            if (doc.status === 'completed') {
              return {
                id: doc.id,
                type: 'success',
                icon: CheckCircle,
                title: 'Document analysis completed',
                description: doc.original_filename || doc.filename,
                time: formatTimeAgo(doc.updated_at),
                timestamp: new Date(doc.updated_at)
              }
            } else if (doc.status === 'processing') {
              return {
                id: doc.id,
                type: 'info',
                icon: Activity,
                title: 'Document processing',
                description: doc.original_filename || doc.filename,
                time: formatTimeAgo(doc.updated_at),
                timestamp: new Date(doc.updated_at)
              }
            } else if (doc.analysis_results && doc.analysis_results.issues_flagged > 0) {
              return {
                id: doc.id,
                type: 'warning',
                icon: AlertCircle,
                title: `${doc.analysis_results.issues_flagged} compliance issue${doc.analysis_results.issues_flagged > 1 ? 's' : ''} detected`,
                description: doc.original_filename || doc.filename,
                time: formatTimeAgo(doc.updated_at),
                timestamp: new Date(doc.updated_at)
              }
            }
            return null
          })
          .filter(n => n !== null)
        
        setNotifications(recentNotifications)
      }
    } catch (error) {
      console.error('Failed to fetch notifications:', error)
    } finally {
      setIsRefreshingNotifications(false)
    }
  }

  const formatTimeAgo = (dateString) => {
    const now = new Date()
    // Parse the date string and ensure it's treated as UTC if no timezone info
    const date = new Date(dateString)
    
    // Calculate difference in milliseconds, then convert to minutes
    const diffInMs = now.getTime() - date.getTime()
    const diffInMinutes = Math.floor(diffInMs / (1000 * 60))
    
    // Handle negative differences (future dates due to timezone issues)
    if (diffInMinutes < 0) return 'Just now'
    if (diffInMinutes < 1) return 'Just now'
    if (diffInMinutes < 60) return `${diffInMinutes} minute${diffInMinutes > 1 ? 's' : ''} ago`
    
    const diffInHours = Math.floor(diffInMinutes / 60)
    if (diffInHours < 24) return `${diffInHours} hour${diffInHours > 1 ? 's' : ''} ago`
    
    const diffInDays = Math.floor(diffInHours / 24)
    return `${diffInDays} day${diffInDays > 1 ? 's' : ''} ago`
  }

  const handleNotifications = () => {
    setNotificationsOpen(!notificationsOpen)
  }

  const handleViewAllNotifications = () => {
    setNotificationsOpen(false)
    navigate('/documents')
  }

  const handleProfile = () => {
    alert('Profile settings coming soon! This will allow you to manage your account, preferences, and billing.')
  }

  const handleSettings = () => {
    setUserMenuOpen(false)
    navigate('/settings')
  }

  const handleLogout = () => {
    if (confirm('Are you sure you want to sign out?')) {
      // Clear authentication data
      localStorage.removeItem('authToken')
      localStorage.removeItem('user')
      navigate('/login')
    }
  }

  const navigation = [
    { 
      name: 'Dashboard', 
      href: '/', 
      icon: BarChart3, 
      description: 'Overview & Analytics',
      current: location.pathname === '/'
    },
    { 
      name: 'Documents', 
      href: '/documents', 
      icon: FileText, 
      description: 'Upload & Manage',
      current: location.pathname === '/documents'
    },
    { 
      name: 'Live Terminal', 
      href: '/terminal', 
      icon: Terminal, 
      description: 'AI Reasoning',
      current: location.pathname === '/terminal'
    },
    { 
      name: 'Settings', 
      href: '/settings', 
      icon: Settings, 
      description: 'Configuration',
      current: location.pathname === '/settings'
    },
  ]

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex">
      {/* Sidebar */}
      <div className="hidden lg:flex lg:flex-shrink-0">
        <div className="flex flex-col w-64">
          <div className="flex flex-col flex-grow bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 pt-5 pb-4 overflow-y-auto">
            {/* Logo */}
            <div className="flex items-center flex-shrink-0 px-4 mb-8">
              <div className="h-10 w-10 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl flex items-center justify-center shadow-lg">
                <Scale className="h-6 w-6 text-white" />
              </div>
              <div className="ml-3">
                <h1 className="text-xl font-bold text-gray-900 dark:text-white">
                  LegaStream
                </h1>
                <p className="text-xs text-gray-600 dark:text-gray-400 font-medium">AI Legal Discovery</p>
              </div>
            </div>

            {/* Navigation */}
            <nav className="mt-5 flex-1 px-2 space-y-1">
              {navigation.map((item) => {
                const Icon = item.icon
                return (
                  <Link
                    key={item.name}
                    to={item.href}
                    className={`group flex items-center px-3 py-3 text-sm font-medium rounded-xl transition-all duration-200 ${
                      item.current
                        ? 'bg-blue-50 dark:bg-gray-900 text-blue-600 dark:text-white shadow-lg'
                        : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-white'
                    }`}
                  >
                    <Icon
                      className={`mr-3 flex-shrink-0 h-5 w-5 ${
                        item.current ? 'text-blue-600 dark:text-blue-400' : 'text-gray-500 dark:text-gray-400 group-hover:text-gray-700 dark:group-hover:text-gray-300'
                      }`}
                    />
                    <div className="flex-1">
                      <div className="text-sm font-medium">{item.name}</div>
                      <div className={`text-xs ${
                        item.current ? 'text-blue-500 dark:text-gray-400' : 'text-gray-500 dark:text-gray-500'
                      }`}>
                        {item.description}
                      </div>
                    </div>
                    {item.current && (
                      <div className="w-1 h-8 bg-blue-500 rounded-full"></div>
                    )}
                  </Link>
                )
              })}
            </nav>

            {/* Bottom Section */}
            <div className="flex-shrink-0 px-4 py-4 border-t border-gray-200 dark:border-gray-700">
              <div className="flex items-center space-x-3 p-3 bg-gray-50 dark:bg-gray-700 rounded-xl">
                <div className="h-8 w-8 bg-gradient-to-br from-green-500 to-emerald-600 rounded-lg flex items-center justify-center">
                  <Activity className="h-4 w-4 text-white" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-gray-900 dark:text-white">System Status</p>
                  <p className="text-xs text-green-600 dark:text-green-400">All systems operational</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="flex flex-col flex-1 overflow-hidden">
        {/* Top Header */}
        <div className="relative z-10 flex-shrink-0 flex h-16 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 lg:border-none shadow-sm">
          {/* Mobile menu button */}
          <button
            type="button"
            className="px-4 border-r border-gray-200 dark:border-gray-700 text-gray-600 dark:text-gray-400 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500 lg:hidden min-h-[44px] min-w-[44px] flex items-center justify-center"
            onClick={() => setMobileMenuOpen(true)}
            aria-label="Open menu"
          >
            <Menu className="h-6 w-6" />
          </button>

          {/* Search bar */}
          <div className="flex-1 px-4 flex justify-between items-center">
            <div className="flex-1 flex">
              <div className="w-full flex md:ml-0">
                <div className="relative w-full text-gray-500 dark:text-gray-400 focus-within:text-gray-700 dark:focus-within:text-gray-300">
                  <div className="absolute inset-y-0 left-0 flex items-center pointer-events-none">
                    <Search className="h-5 w-5" />
                  </div>
                  <input
                    className="block w-full h-full pl-8 pr-3 py-2 border-transparent text-gray-900 dark:text-gray-300 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:placeholder-gray-400 dark:focus:placeholder-gray-300 focus:ring-0 focus:border-transparent bg-gray-100 dark:bg-gray-700 rounded-lg"
                    placeholder="Search documents, cases, or data..."
                    type="search"
                  />
                </div>
              </div>
            </div>

            {/* Right side items */}
            <div className="ml-4 flex items-center md:ml-6 space-x-4">
              {/* Status Indicators */}
              <div className="hidden lg:flex items-center space-x-3">
                <div className="flex items-center space-x-2 px-3 py-1 bg-green-50 dark:bg-green-900/50 text-green-700 dark:text-green-400 rounded-full text-xs font-medium border border-green-200 dark:border-green-800">
                  <div className="w-2 h-2 bg-green-500 dark:bg-green-400 rounded-full animate-pulse"></div>
                  <span>AI Active</span>
                </div>
                <div className="flex items-center space-x-2 px-3 py-1 bg-blue-50 dark:bg-blue-900/50 text-blue-700 dark:text-blue-400 rounded-full text-xs font-medium border border-blue-200 dark:border-blue-800">
                  <Shield className="h-3 w-3" />
                  <span>Secure</span>
                </div>
              </div>

              {/* Notifications */}
              <div className="relative" ref={notificationsRef}>
                <button 
                  onClick={handleNotifications}
                  className="bg-gray-100 dark:bg-gray-700 p-2 rounded-lg text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors relative min-h-[44px] min-w-[44px] flex items-center justify-center"
                  aria-label="Notifications"
                >
                  <Bell className="h-5 w-5" />
                  {notifications.length > 0 && (
                    <span className="absolute top-0 right-0 block h-2 w-2 rounded-full bg-red-400" aria-label={`${notifications.length} unread notifications`}></span>
                  )}
                </button>

                {/* Notifications Dropdown */}
                {notificationsOpen && (
                  <div className="origin-top-right absolute right-0 mt-2 w-80 rounded-xl shadow-lg py-1 bg-white dark:bg-gray-700 ring-1 ring-black ring-opacity-5 focus:outline-none z-50 border border-gray-200 dark:border-gray-600">
                    <div className="px-4 py-3 border-b border-gray-200 dark:border-gray-600 flex items-center justify-between">
                      <h3 className="text-sm font-medium text-gray-900 dark:text-white">Notifications</h3>
                      <button
                        onClick={(e) => {
                          e.stopPropagation()
                          fetchNotifications()
                        }}
                        disabled={isRefreshingNotifications}
                        className="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors disabled:opacity-50"
                        title="Refresh notifications"
                      >
                        <RefreshCw className={`h-4 w-4 text-gray-600 dark:text-gray-400 ${isRefreshingNotifications ? 'animate-spin' : ''}`} />
                      </button>
                    </div>
                    <div className="max-h-64 overflow-y-auto">
                      {notifications.length === 0 ? (
                        <div className="px-4 py-8 text-center">
                          <Bell className="h-8 w-8 text-gray-400 dark:text-gray-600 mx-auto mb-2" />
                          <p className="text-sm text-gray-500 dark:text-gray-400">No notifications</p>
                        </div>
                      ) : (
                        notifications.map((notification) => {
                          const Icon = notification.icon
                          return (
                            <div 
                              key={notification.id} 
                              className="px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-600 transition-colors cursor-pointer"
                              onClick={() => {
                                setNotificationsOpen(false)
                                navigate('/documents')
                              }}
                            >
                              <div className="flex items-start space-x-3">
                                <Icon className={`h-5 w-5 mt-0.5 ${
                                  notification.type === 'success' ? 'text-green-500' :
                                  notification.type === 'warning' ? 'text-amber-500' :
                                  'text-blue-500'
                                }`} />
                                <div className="flex-1 min-w-0">
                                  <p className="text-sm font-medium text-gray-900 dark:text-white">
                                    {notification.title}
                                  </p>
                                  <p className="text-xs text-gray-600 dark:text-gray-400 mt-0.5 truncate">
                                    {notification.description}
                                  </p>
                                  <p className="text-xs text-gray-500 dark:text-gray-500 mt-1">
                                    {notification.time}
                                  </p>
                                </div>
                              </div>
                            </div>
                          )
                        })
                      )}
                    </div>
                    <div className="px-4 py-2 border-t border-gray-200 dark:border-gray-600">
                      <button 
                        onClick={handleViewAllNotifications}
                        className="text-xs text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium"
                      >
                        View all notifications
                      </button>
                    </div>
                  </div>
                )}
              </div>

              {/* User menu */}
              <div className="relative" ref={userMenuRef}>
                <button
                  onClick={() => setUserMenuOpen(!userMenuOpen)}
                  className="max-w-xs bg-gray-100 dark:bg-gray-700 rounded-lg flex items-center text-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-white dark:focus:ring-offset-gray-800 focus:ring-blue-500 p-2 min-h-[44px]"
                  aria-label="User menu"
                  aria-expanded={userMenuOpen}
                >
                  <div className="h-8 w-8 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-lg flex items-center justify-center">
                    <User className="h-4 w-4 text-white" />
                  </div>
                  <div className="ml-3 hidden lg:block text-left">
                    <p className="text-sm font-medium text-gray-900 dark:text-white">
                      {user ? user.full_name || `${user.first_name} ${user.last_name}` : 'Admin User'}
                    </p>
                    <p className="text-xs text-gray-600 dark:text-gray-400">
                      {user ? user.email : 'admin@legastream.com'}
                    </p>
                  </div>
                  <ChevronDown className="ml-2 h-4 w-4 text-gray-600 dark:text-gray-400" />
                </button>

                {/* User dropdown */}
                {userMenuOpen && (
                  <div className="origin-top-right absolute right-0 mt-2 w-56 rounded-xl shadow-lg py-1 bg-white dark:bg-gray-700 ring-1 ring-black ring-opacity-5 focus:outline-none z-50 border border-gray-200 dark:border-gray-600">
                    <button 
                      onClick={handleProfile}
                      className="flex items-center w-full px-4 py-3 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 hover:text-gray-900 dark:hover:text-white transition-colors"
                    >
                      <UserCircle className="h-4 w-4 mr-3" />
                      Your Profile
                    </button>
                    <button 
                      onClick={handleSettings}
                      className="flex items-center w-full px-4 py-3 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 hover:text-gray-900 dark:hover:text-white transition-colors"
                    >
                      <Cog className="h-4 w-4 mr-3" />
                      Settings
                    </button>
                    <div className="border-t border-gray-200 dark:border-gray-600 my-1"></div>
                    <button 
                      onClick={handleLogout}
                      className="flex items-center w-full px-4 py-3 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 hover:text-gray-900 dark:hover:text-white transition-colors"
                    >
                      <LogOut className="h-4 w-4 mr-3" />
                      Sign out
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Main content */}
        <main className="flex-1 relative overflow-y-auto focus:outline-none bg-gray-50 dark:bg-gray-900">
          <div className="min-h-full flex items-start justify-center py-8">
            <div className="w-full max-w-7xl mx-auto px-6 lg:px-8">
              <div className="grid grid-cols-1 gap-8">
                <Outlet />
              </div>
            </div>
          </div>
        </main>
      </div>

      {/* Mobile menu overlay */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 flex z-40 lg:hidden">
          <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setMobileMenuOpen(false)} />
          
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white dark:bg-gray-800">
            <div className="absolute top-0 right-0 -mr-12 pt-2">
              <button
                type="button"
                className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                onClick={() => setMobileMenuOpen(false)}
              >
                <X className="h-6 w-6 text-white" />
              </button>
            </div>

            <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
              <div className="flex-shrink-0 flex items-center px-4 mb-8">
                <div className="h-10 w-10 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl flex items-center justify-center shadow-lg">
                  <Scale className="h-6 w-6 text-white" />
                </div>
                <div className="ml-3">
                  <h1 className="text-xl font-bold text-gray-900 dark:text-white">LegaStream</h1>
                  <p className="text-xs text-gray-600 dark:text-gray-400 font-medium">AI Legal Discovery</p>
                </div>
              </div>
              
              <nav className="mt-5 px-2 space-y-1">
                {navigation.map((item) => {
                  const Icon = item.icon
                  return (
                    <Link
                      key={item.name}
                      to={item.href}
                      className={`group flex items-center px-3 py-3 text-sm font-medium rounded-xl transition-all duration-200 ${
                        item.current
                          ? 'bg-blue-50 dark:bg-gray-900 text-blue-600 dark:text-white shadow-lg'
                          : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-white'
                      }`}
                      onClick={() => setMobileMenuOpen(false)}
                    >
                      <Icon className={`mr-3 flex-shrink-0 h-5 w-5 ${
                        item.current ? 'text-blue-600 dark:text-blue-400' : 'text-gray-500 dark:text-gray-400 group-hover:text-gray-700 dark:group-hover:text-gray-300'
                      }`} />
                      <div className="flex-1">
                        <div className="text-sm font-medium">{item.name}</div>
                        <div className={`text-xs ${
                          item.current ? 'text-blue-500 dark:text-gray-400' : 'text-gray-500 dark:text-gray-500'
                        }`}>
                          {item.description}
                        </div>
                      </div>
                    </Link>
                  )
                })}
              </nav>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}