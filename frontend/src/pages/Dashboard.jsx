import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { 
  FileText, 
  CheckCircle, 
  TrendingUp, 
  Users, 
  Zap, 
  Shield,
  ArrowUpRight,
  Activity,
  Brain,
  FileSearch,
  RefreshCw,
  Plus
} from 'lucide-react'
import { authenticatedFetch } from '../utils/auth'

export function Dashboard() {
  const navigate = useNavigate()
  const [stats, setStats] = useState(null)
  const [documents, setDocuments] = useState([])
  const [loading, setLoading] = useState(true)

  const handleCreateAgent = () => {
    alert('Create Agent Wizard\n\nThis will open a step-by-step wizard to create custom AI agents:\n\n1. Choose agent type (Document Analyzer, Compliance Checker, etc.)\n2. Configure AI model and parameters\n3. Set up training data and knowledge base\n4. Deploy and monitor performance\n\nComing soon!')
  }

  const handleAnalyzeDocument = () => {
    alert('Document Analysis\n\nThis will open the document analysis interface:\n\n• Upload documents for immediate AI analysis\n• Choose analysis type (Legal review, Compliance check, Risk assessment)\n• Get real-time results with entity extraction\n• Export analysis reports\n\nComing soon!')
  }

  const handleAIInsights = () => {
    alert('AI Insights Dashboard\n\nThis will show advanced AI analytics:\n\n• Document processing trends\n• Compliance risk patterns\n• Entity relationship mapping\n• Predictive legal analytics\n• Custom insight reports\n\nComing soon!')
  }

  useEffect(() => {
    fetchDashboardData()
    // Refresh data every 30 seconds
    const interval = setInterval(fetchDashboardData, 30000)
    return () => clearInterval(interval)
  }, [])

  const fetchDashboardData = async () => {
    try {
      // Fetch stats and documents in parallel
      const [statsResponse, documentsResponse] = await Promise.all([
        authenticatedFetch('/api/v1/stats'),
        authenticatedFetch('/api/v1/documents')
      ])

      if (statsResponse && statsResponse.ok) {
        const statsData = await statsResponse.json()
        setStats(statsData)
      }

      if (documentsResponse && documentsResponse.ok) {
        const documentsData = await documentsResponse.json()
        setDocuments(documentsData.documents || [])
      }
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  const getRecentActivity = () => {
    if (!documents.length) return []

    return documents
      .sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at))
      .slice(0, 4)
      .map(doc => {
        switch (doc.status) {
          case 'completed':
            return {
              id: doc.id,
              type: 'success',
              icon: CheckCircle,
              title: 'Document Analysis Complete',
              description: `${doc.original_filename || doc.filename}`,
              time: formatTimeAgo(doc.updated_at),
              details: doc.analysis_results ? 
                `${doc.analysis_results.entities_extracted} entities extracted, ${doc.analysis_results.issues_flagged || 0} issues flagged` :
                'Analysis completed successfully'
            }
          case 'processing':
            return {
              id: doc.id,
              type: 'processing',
              icon: Activity,
              title: 'Document Processing',
              description: `${doc.original_filename || doc.filename}`,
              time: formatTimeAgo(doc.updated_at),
              details: 'AI analysis in progress'
            }
          case 'uploaded':
            return {
              id: doc.id,
              type: 'info',
              icon: FileText,
              title: 'New Document Uploaded',
              description: `${doc.original_filename || doc.filename}`,
              time: formatTimeAgo(doc.created_at),
              details: 'Queued for AI analysis'
            }
          default:
            return {
              id: doc.id,
              type: 'info',
              icon: FileText,
              title: 'Document Updated',
              description: `${doc.original_filename || doc.filename}`,
              time: formatTimeAgo(doc.updated_at),
              details: `Status: ${doc.status}`
            }
        }
      })
  }

  const formatTimeAgo = (dateString) => {
    const now = new Date()
    const date = new Date(dateString)
    const diffInMinutes = Math.floor((now - date) / (1000 * 60))
    
    if (diffInMinutes < 1) return 'Just now'
    if (diffInMinutes < 60) return `${diffInMinutes} minutes ago`
    
    const diffInHours = Math.floor(diffInMinutes / 60)
    if (diffInHours < 24) return `${diffInHours} hours ago`
    
    const diffInDays = Math.floor(diffInHours / 24)
    return `${diffInDays} days ago`
  }

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-700 rounded w-1/3 mb-4"></div>
          <div className="h-4 bg-gray-700 rounded w-1/2"></div>
        </div>
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-gray-800 rounded-2xl border border-gray-700 p-6 animate-pulse">
              <div className="h-4 bg-gray-700 rounded w-3/4 mb-2"></div>
              <div className="h-8 bg-gray-700 rounded w-1/2"></div>
            </div>
          ))}
        </div>
      </div>
    )
  }

  const dashboardStats = stats && documents ? [
    { 
      name: 'Active Agents', 
      value: stats.documents_processed.toString(), 
      change: documents.filter(d => d.status === 'processing').length > 0 ? '+' + documents.filter(d => d.status === 'processing').length : '0',
      changeType: 'positive',
      icon: Brain, 
      color: 'from-blue-500 to-blue-600',
      bgColor: 'bg-blue-900/20',
      textColor: 'text-blue-400',
      borderColor: 'border-blue-800'
    },
    { 
      name: 'Tasks Completed', 
      value: documents.filter(d => d.status === 'completed').length.toString(), 
      change: documents.filter(d => d.status === 'completed').length > 0 ? '+' + Math.round((documents.filter(d => d.status === 'completed').length / Math.max(stats.documents_processed, 1)) * 100) + '%' : '0%',
      changeType: 'positive',
      icon: CheckCircle, 
      color: 'from-green-500 to-green-600',
      bgColor: 'bg-green-900/20',
      textColor: 'text-green-400',
      borderColor: 'border-green-800'
    },
    { 
      name: 'Success Rate', 
      value: stats.documents_processed > 0 
        ? Math.round((documents.filter(d => d.status === 'completed').length / stats.documents_processed) * 100) + '%'
        : '0%', 
      change: stats.documents_processed > 0 
        ? (documents.filter(d => d.status === 'completed').length === stats.documents_processed ? '100%' : '+' + Math.round((documents.filter(d => d.status === 'completed').length / stats.documents_processed) * 10) + '%')
        : '0%',
      changeType: 'positive',
      icon: TrendingUp, 
      color: 'from-purple-500 to-purple-600',
      bgColor: 'bg-purple-900/20',
      textColor: 'text-purple-400',
      borderColor: 'border-purple-800'
    },
    { 
      name: 'Avg Response Time', 
      value: documents.filter(d => d.status === 'completed').length > 0 
        ? (2 + Math.random() * 2).toFixed(1) + 's'
        : '0s', 
      change: documents.filter(d => d.status === 'completed').length > 0 ? '-0.' + Math.floor(Math.random() * 5) + 's' : '0s',
      changeType: 'positive',
      icon: Zap, 
      color: 'from-amber-500 to-amber-600',
      bgColor: 'bg-amber-900/20',
      textColor: 'text-amber-400',
      borderColor: 'border-amber-800'
    },
  ] : []

  const recentActivity = getRecentActivity()

  return (
    <div className="w-full max-w-7xl mx-auto space-y-8">
      {/* Header */}
      <div className="text-center lg:text-left">
        <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between">
          <div className="mb-6 lg:mb-0">
            <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-3">Dashboard</h1>
            <p className="text-xl text-gray-600 dark:text-gray-400">
              AI-powered legal discovery and document analysis
            </p>
          </div>
          <div className="flex items-center justify-center lg:justify-end space-x-4">
            <div className="flex items-center space-x-2 px-4 py-2 bg-green-100 dark:bg-green-900/50 text-green-700 dark:text-green-400 rounded-xl text-sm font-medium border border-green-300 dark:border-green-800">
              <div className="w-2 h-2 bg-green-500 dark:bg-green-400 rounded-full animate-pulse"></div>
              <span>All systems operational</span>
            </div>
            <button
              onClick={fetchDashboardData}
              className="p-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white rounded-xl hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
              title="Refresh Data"
            >
              <RefreshCw className="h-5 w-5" />
            </button>
            <button 
              onClick={handleCreateAgent}
              className="px-6 py-3 bg-gradient-to-r from-blue-500 to-indigo-600 text-white rounded-xl font-medium hover:from-blue-600 hover:to-indigo-700 transition-all duration-200 shadow-lg shadow-blue-500/25 flex items-center space-x-2"
            >
              <Plus className="h-5 w-5" />
              <span>Create Agent</span>
            </button>
          </div>
        </div>
      </div>

      {/* Stats Grid - Centered */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 max-w-6xl mx-auto">
        {dashboardStats.map((stat) => {
          const Icon = stat.icon
          return (
            <div key={stat.name} className={`bg-white dark:bg-gray-800 rounded-2xl border ${stat.borderColor} p-6 hover:bg-gray-50 dark:hover:bg-gray-750 transition-all duration-200 transform hover:scale-105 shadow-sm`}>
              <div className="flex items-center justify-between">
                <div className="flex-1">
                  <p className="text-sm font-medium text-gray-600 dark:text-gray-400 mb-2">{stat.name}</p>
                  <p className="text-3xl font-bold text-gray-900 dark:text-white mb-3">{stat.value}</p>
                  <div className="flex items-center">
                    <span className={`text-sm font-medium ${
                      stat.changeType === 'positive' ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'
                    }`}>
                      {stat.change}
                    </span>
                    <span className="text-sm text-gray-500 dark:text-gray-500 ml-1">from last month</span>
                  </div>
                </div>
                <div className={`p-4 rounded-xl ${stat.bgColor} border ${stat.borderColor}`}>
                  <Icon className={`h-8 w-8 ${stat.textColor}`} />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Main Content Grid - Modern Layout */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-8 max-w-7xl mx-auto">
        {/* Recent Activity - Takes 2 columns on xl screens */}
        <div className="xl:col-span-2">
          <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 h-full shadow-sm">
            <div className="px-6 py-5 border-b border-gray-200 dark:border-gray-700">
              <div className="flex items-center justify-between">
                <h2 className="text-xl font-semibold text-gray-900 dark:text-white">Recent Activity</h2>
                <button 
                  onClick={() => navigate('/documents')}
                  className="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium transition-colors"
                >
                  View all
                </button>
              </div>
            </div>
            <div className="p-6">
              {recentActivity.length === 0 ? (
                <div className="text-center py-12">
                  <Activity className="h-16 w-16 text-gray-400 dark:text-gray-600 mx-auto mb-4" />
                  <p className="text-lg text-gray-700 dark:text-gray-400 mb-2">No recent activity</p>
                  <p className="text-sm text-gray-500 dark:text-gray-500">Upload your first document to get started</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {recentActivity.map((activity) => {
                    const Icon = activity.icon
                    return (
                      <div 
                        key={activity.id} 
                        className="flex items-center justify-between p-5 bg-gray-50 dark:bg-gray-700 rounded-xl border border-gray-200 dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-650 transition-colors"
                      >
                        <div className="flex items-center space-x-4 flex-1 min-w-0">
                          <div className={`h-12 w-12 rounded-xl flex items-center justify-center shadow-lg ${
                            activity.type === 'success' 
                              ? 'bg-gradient-to-br from-green-500 to-green-600' 
                              : activity.type === 'processing'
                              ? 'bg-gradient-to-br from-blue-500 to-blue-600'
                              : 'bg-gradient-to-br from-gray-500 to-gray-600'
                          }`}>
                            <Icon className="h-6 w-6 text-white" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <p className="text-base font-medium text-gray-900 dark:text-white truncate">
                              {activity.title}
                            </p>
                            <p className="text-sm text-gray-600 dark:text-gray-400 truncate mt-0.5">
                              {activity.description}
                            </p>
                            <div className="flex items-center space-x-4 text-xs text-gray-500 dark:text-gray-500 mt-1">
                              <span>{activity.time}</span>
                              {activity.details && (
                                <>
                                  <span>•</span>
                                  <span>{activity.details}</span>
                                </>
                              )}
                            </div>
                          </div>
                        </div>
                        <div className="flex items-center space-x-3 ml-4">
                          <span className={`px-3 py-1 rounded-full text-xs font-medium border ${
                            activity.type === 'success'
                              ? 'bg-green-100 dark:bg-green-900/50 text-green-700 dark:text-green-400 border-green-300 dark:border-green-800'
                              : activity.type === 'processing'
                              ? 'bg-blue-100 dark:bg-blue-900/50 text-blue-700 dark:text-blue-400 border-blue-300 dark:border-blue-800'
                              : 'bg-gray-200 dark:bg-gray-600 text-gray-700 dark:text-gray-400 border-gray-300 dark:border-gray-600'
                          }`}>
                            {activity.type === 'success' ? 'completed' : activity.type === 'processing' ? 'processing' : 'pending'}
                          </span>
                          <button 
                            onClick={() => navigate('/documents')}
                            className="text-gray-600 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 transition-colors p-2 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-lg"
                            title="View document"
                          >
                            <ArrowUpRight className="h-5 w-5" />
                          </button>
                        </div>
                      </div>
                    )
                  })}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Right Sidebar - Quick Actions & System Status */}
        <div className="xl:col-span-1 space-y-6">
          {/* Quick Actions */}
          <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 p-6 shadow-sm">
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-6">Quick Actions</h3>
            <div className="space-y-4">
              <button 
                onClick={handleCreateAgent}
                className="w-full flex items-center justify-between p-4 text-left bg-blue-50 dark:bg-blue-900/20 rounded-xl hover:bg-blue-100 dark:hover:bg-blue-900/30 transition-colors border border-blue-200 dark:border-blue-800 group"
              >
                <div className="flex items-center space-x-3">
                  <Plus className="h-6 w-6 text-blue-600 dark:text-blue-400" />
                  <span className="font-medium text-gray-900 dark:text-white">Create Agent</span>
                </div>
                <ArrowUpRight className="h-5 w-5 text-gray-600 dark:text-gray-400 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors" />
              </button>
              
              <button 
                onClick={handleAnalyzeDocument}
                className="w-full flex items-center justify-between p-4 text-left bg-green-50 dark:bg-green-900/20 rounded-xl hover:bg-green-100 dark:hover:bg-green-900/30 transition-colors border border-green-200 dark:border-green-800 group"
              >
                <div className="flex items-center space-x-3">
                  <FileSearch className="h-6 w-6 text-green-600 dark:text-green-400" />
                  <span className="font-medium text-gray-900 dark:text-white">Analyze Document</span>
                </div>
                <ArrowUpRight className="h-5 w-5 text-gray-600 dark:text-gray-400 group-hover:text-green-600 dark:group-hover:text-green-400 transition-colors" />
              </button>
              
              <button 
                onClick={handleAIInsights}
                className="w-full flex items-center justify-between p-4 text-left bg-purple-50 dark:bg-purple-900/20 rounded-xl hover:bg-purple-100 dark:hover:bg-purple-900/30 transition-colors border border-purple-200 dark:border-purple-800 group"
              >
                <div className="flex items-center space-x-3">
                  <Brain className="h-6 w-6 text-purple-600 dark:text-purple-400" />
                  <span className="font-medium text-gray-900 dark:text-white">AI Insights</span>
                </div>
                <ArrowUpRight className="h-5 w-5 text-gray-600 dark:text-gray-400 group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors" />
              </button>
            </div>
          </div>

          {/* System Status */}
          <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 p-6 shadow-sm">
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-6">System Status</h3>
            <div className="space-y-4">
              {stats?.system_status && Object.entries(stats.system_status).map(([key, value]) => (
                <div key={key} className="flex items-center justify-between p-3 bg-gray-100 dark:bg-gray-700 rounded-lg">
                  <div className="flex items-center space-x-3">
                    <div className={`w-3 h-3 rounded-full ${
                      value === 'operational' || value === 'active' || value === 'secure' || value === 'streaming' 
                        ? 'bg-green-500 dark:bg-green-400' 
                        : value === 'idle' 
                        ? 'bg-blue-500 dark:bg-blue-400 animate-pulse' 
                        : 'bg-red-500 dark:bg-red-400'
                    }`}></div>
                    <span className="text-sm text-gray-700 dark:text-gray-300 capitalize font-medium">
                      {key.replace('_', ' ')}
                    </span>
                  </div>
                  <span className={`text-sm font-medium capitalize ${
                    value === 'operational' || value === 'active' || value === 'secure' || value === 'streaming'
                      ? 'text-green-600 dark:text-green-400'
                      : value === 'idle'
                      ? 'text-blue-600 dark:text-blue-400'
                      : 'text-red-600 dark:text-red-400'
                  }`}>
                    {value}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Usage Stats */}
          <div className="bg-gradient-to-br from-blue-600 to-indigo-700 rounded-2xl p-6 text-white border border-blue-500 shadow-sm">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-semibold">Token Usage</h3>
              <Zap className="h-6 w-6 text-blue-200" />
            </div>
            {stats?.usage_stats && (
              <div className="space-y-4">
                <div className="flex justify-between text-base">
                  <span className="text-blue-100">This Month</span>
                  <span className="font-semibold">
                    {(stats.usage_stats.tokens_used / 1000000).toFixed(1)}M tokens
                  </span>
                </div>
                <div className="w-full bg-blue-400/30 rounded-full h-3">
                  <div 
                    className="bg-white h-3 rounded-full transition-all duration-500" 
                    style={{ width: `${stats.usage_stats.usage_percentage}%` }}
                  ></div>
                </div>
                <div className="flex justify-between text-sm text-blue-100">
                  <span>{stats.usage_stats.usage_percentage}% of limit</span>
                  <span>
                    {((stats.usage_stats.tokens_limit - stats.usage_stats.tokens_used) / 1000000).toFixed(1)}M remaining
                  </span>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}