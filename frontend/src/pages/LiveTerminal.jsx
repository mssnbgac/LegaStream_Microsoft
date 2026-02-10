import React, { useState, useEffect, useRef } from 'react'
import { 
  Terminal, 
  Wifi, 
  WifiOff, 
  Play, 
  Pause, 
  RotateCcw, 
  Download,
  Maximize2,
  Settings,
  Activity,
  Zap,
  Brain,
  Shield
} from 'lucide-react'

export function LiveTerminal() {
  const [messages, setMessages] = useState([])
  const [isConnected, setIsConnected] = useState(false)
  const [isPaused, setIsPaused] = useState(false)
  const [connectionStatus, setConnectionStatus] = useState('Connecting...')
  const [isFullscreen, setIsFullscreen] = useState(false)
  const messagesEndRef = useRef(null)
  const terminalRef = useRef(null)

  // Enhanced mock WebSocket connection
  useEffect(() => {
    let mounted = true
    
    // Simulate connection process
    setTimeout(() => {
      if (mounted) {
        setIsConnected(true)
        setConnectionStatus('Connected to AI Agent')
      }
    }, 1000)

    // Enhanced mock messages for demonstration
    const mockMessages = [
      { id: 1, type: 'system', content: '🚀 LegaStream AI Agent v2.1.0 initialized', timestamp: new Date(), category: 'startup' },
      { id: 2, type: 'system', content: '🔐 Secure sandbox environment activated', timestamp: new Date(), category: 'security' },
      { id: 3, type: 'system', content: '🧠 Neural language model loaded (GPT-4 Turbo)', timestamp: new Date(), category: 'ai' },
      { id: 4, type: 'info', content: '💡 This is a demo terminal showing simulated AI reasoning', timestamp: new Date(), category: 'info' },
      { id: 5, type: 'info', content: '📝 Real-time streaming will be available in a future update', timestamp: new Date(), category: 'info' },
      { id: 6, type: 'reasoning', content: '📄 Analyzing document structure and metadata...', timestamp: new Date(), category: 'processing' },
      { id: 7, type: 'reasoning', content: '🔍 Extracting legal entities from pages 1-50 of 247...', timestamp: new Date(), category: 'extraction' },
      { id: 8, type: 'tool', content: '⚖️ Searching case law database for precedents...', timestamp: new Date(), category: 'research' },
      { id: 9, type: 'reasoning', content: '📚 Found 12 relevant case citations: Brown v. Board (1954), Roe v. Wade (1973), Miranda v. Arizona (1966)...', timestamp: new Date(), category: 'analysis' },
      { id: 10, type: 'warning', content: '⚠️ Potential GDPR compliance issue detected in Clause 4.2', timestamp: new Date(), category: 'compliance' },
      { id: 11, type: 'reasoning', content: '🔍 Cross-referencing with EU privacy regulations...', timestamp: new Date(), category: 'compliance' },
      { id: 12, type: 'tool', content: '🤖 Running compliance analysis algorithm...', timestamp: new Date(), category: 'ai' },
      { id: 13, type: 'success', content: '✅ Document analysis complete - 98.7% confidence score', timestamp: new Date(), category: 'completion' },
      { id: 14, type: 'reasoning', content: '📊 Generating comprehensive legal summary...', timestamp: new Date(), category: 'summary' },
    ]

    // Simulate real-time message streaming with realistic delays
    const timeouts = mockMessages.map((message, index) => 
      setTimeout(() => {
        if (mounted && !isPaused) {
          setMessages(prev => [...prev, message])
        }
      }, index * 1500 + 2000) // Start after connection is established
    )

    return () => {
      mounted = false
      timeouts.forEach(timeout => clearTimeout(timeout))
      setIsConnected(false)
      setConnectionStatus('Disconnected')
    }
  }, []) // Remove isPaused from dependencies to prevent re-running

  // Auto-scroll to bottom
  useEffect(() => {
    if (!isPaused) {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
    }
  }, [messages, isPaused])

  const getMessageStyle = (type) => {
    const styles = {
      system: 'text-blue-400',
      reasoning: 'text-terminal-green',
      tool: 'text-purple-400',
      warning: 'text-terminal-amber',
      error: 'text-terminal-red',
      success: 'text-green-400',
      info: 'text-cyan-400'
    }
    return styles[type] || 'text-gray-300'
  }

  const getCategoryIcon = (category) => {
    const icons = {
      startup: '🚀',
      security: '🔐',
      ai: '🧠',
      processing: '⚙️',
      extraction: '🔍',
      research: '📚',
      analysis: '📊',
      compliance: '⚖️',
      completion: '✅',
      summary: '📋'
    }
    return icons[category] || '💬'
  }

  const formatTimestamp = (timestamp) => {
    return timestamp.toLocaleTimeString('en-US', { 
      hour12: false,
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      fractionalSecondDigits: 3
    })
  }

  const clearTerminal = () => {
    setMessages([])
  }

  const downloadLogs = () => {
    const logs = messages.map(msg => 
      `[${formatTimestamp(msg.timestamp)}] ${msg.type.toUpperCase()}: ${msg.content}`
    ).join('\n')
    
    const blob = new Blob([logs], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `legastream-logs-${new Date().toISOString().split('T')[0]}.txt`
    a.click()
    URL.revokeObjectURL(url)
  }

  return (
    <div className={`w-full max-w-7xl mx-auto ${isFullscreen ? 'fixed inset-0 z-50 bg-white dark:bg-gray-900 p-6' : ''}`}>
      {/* Header - Centered */}
      <div className="mb-8">
        <div className="text-center lg:text-left">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between">
            <div className="mb-6 lg:mb-0">
              <h1 className="text-4xl font-bold text-gray-900 dark:text-white flex items-center justify-center lg:justify-start mb-3">
                <div className="p-3 bg-gradient-to-br from-green-500 to-emerald-600 rounded-xl mr-4 shadow-lg">
                  <Terminal className="h-10 w-10 text-white" />
                </div>
                Live Logic Terminal
              </h1>
              <p className="text-xl text-gray-600 dark:text-gray-400">
                Real-time AI agent reasoning and Chain-of-Thought streaming
              </p>
            </div>
            
            <div className="flex items-center justify-center lg:justify-end space-x-4">
              {/* Connection Status */}
              <div className="flex items-center space-x-2 px-4 py-2 bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
                {isConnected ? (
                  <>
                    <div className="flex items-center space-x-2">
                      <div className="w-2 h-2 bg-green-500 dark:bg-green-400 rounded-full animate-pulse"></div>
                      <Wifi className="h-4 w-4 text-green-600 dark:text-green-400" />
                    </div>
                    <span className="text-sm font-medium text-green-600 dark:text-green-400">{connectionStatus}</span>
                  </>
                ) : (
                  <>
                    <WifiOff className="h-4 w-4 text-red-600 dark:text-red-400" />
                    <span className="text-sm font-medium text-red-600 dark:text-red-400">{connectionStatus}</span>
                  </>
                )}
              </div>

              {/* Control Buttons */}
              <div className="flex items-center space-x-2">
                <button
                  onClick={() => setIsPaused(!isPaused)}
                  className="p-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-200 dark:hover:bg-gray-700 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 transition-colors"
                  title={isPaused ? 'Resume' : 'Pause'}
                >
                  {isPaused ? <Play className="h-4 w-4" /> : <Pause className="h-4 w-4" />}
                </button>
                
                <button
                  onClick={clearTerminal}
                  className="p-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-200 dark:hover:bg-gray-700 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 transition-colors"
                  title="Clear Terminal"
                >
                  <RotateCcw className="h-4 w-4" />
                </button>
                
                <button
                  onClick={downloadLogs}
                  className="p-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-200 dark:hover:bg-gray-700 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 transition-colors"
                  title="Download Logs"
                >
                  <Download className="h-4 w-4" />
                </button>
                
                <button
                  onClick={() => setIsFullscreen(!isFullscreen)}
                  className="p-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-200 dark:hover:bg-gray-700 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 transition-colors"
                  title="Toggle Fullscreen"
                >
                  <Maximize2 className="h-4 w-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Stats Bar - Centered Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 mb-8 max-w-5xl mx-auto">
        <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700 text-center">
          <div className="flex flex-col items-center space-y-3">
            <div className="p-3 bg-blue-100 dark:bg-blue-900/50 rounded-lg border border-blue-200 dark:border-blue-800">
              <Activity className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Messages</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{messages.length}</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700 text-center">
          <div className="flex flex-col items-center space-y-3">
            <div className="p-3 bg-green-100 dark:bg-green-900/50 rounded-lg border border-green-200 dark:border-green-800">
              <Zap className="h-6 w-6 text-green-600 dark:text-green-400" />
            </div>
            <div>
              <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Processing Speed</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">2.3s/msg</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700 text-center">
          <div className="flex flex-col items-center space-y-3">
            <div className="p-3 bg-purple-100 dark:bg-purple-900/50 rounded-lg border border-purple-200 dark:border-purple-800">
              <Brain className="h-6 w-6 text-purple-600 dark:text-purple-400" />
            </div>
            <div>
              <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">AI Confidence</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">98.7%</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700 text-center">
          <div className="flex flex-col items-center space-y-3">
            <div className="p-3 bg-emerald-100 dark:bg-emerald-900/50 rounded-lg border border-emerald-200 dark:border-emerald-800">
              <Shield className="h-6 w-6 text-emerald-600 dark:text-emerald-400" />
            </div>
            <div>
              <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Security Status</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">Secure</p>
            </div>
          </div>
        </div>
      </div>

      {/* Enhanced Terminal Window - Centered */}
      <div className="max-w-6xl mx-auto">
        <div className="terminal-window shadow-2xl">
          <div className="terminal-header">
            <div className="flex items-center space-x-2">
              <div className="terminal-dot bg-red-500"></div>
              <div className="terminal-dot bg-yellow-500"></div>
              <div className="terminal-dot bg-green-500"></div>
            </div>
            <div className="flex-1 flex items-center justify-center">
              <span className="text-gray-400 text-sm font-mono flex items-center space-x-2">
                <Terminal className="h-4 w-4" />
                <span>LegaStream AI Agent Terminal</span>
                {isConnected && (
                  <div className="flex items-center space-x-1 ml-4">
                    <div className="w-1 h-1 bg-green-400 rounded-full animate-pulse"></div>
                    <span className="text-xs text-green-400">LIVE</span>
                  </div>
                )}
              </span>
            </div>
            <div className="flex items-center space-x-2">
              <Settings className="h-4 w-4 text-gray-500 hover:text-gray-300 cursor-pointer" />
            </div>
          </div>
          
          <div 
            ref={terminalRef}
            className="terminal-content terminal-scroll"
            style={{ height: isFullscreen ? 'calc(100vh - 300px)' : '600px' }}
          >
            {messages.length === 0 ? (
              <div className="text-gray-500 dark:text-gray-500 text-center py-16">
                <Terminal className="h-16 w-16 mx-auto mb-6 opacity-50" />
                <p className="text-xl mb-3">Waiting for AI agent activity...</p>
                <p className="text-base opacity-75">Upload a document to see the reasoning process in real-time</p>
              </div>
            ) : (
              <div className="space-y-4">
                {messages.map((message) => (
                  <div key={message.id} className="flex items-start space-x-4 group hover:bg-gray-100 dark:hover:bg-gray-800/50 rounded-lg p-3 -m-3 transition-colors">
                    <span className="text-gray-500 dark:text-gray-500 text-xs font-mono w-28 flex-shrink-0 pt-1">
                      [{formatTimestamp(message.timestamp)}]
                    </span>
                    <span className={`text-xs uppercase font-bold w-24 flex-shrink-0 pt-1 ${
                      message.type === 'system' ? 'text-blue-600 dark:text-blue-400' :
                      message.type === 'reasoning' ? 'text-green-600 dark:text-terminal-green' :
                      message.type === 'tool' ? 'text-purple-600 dark:text-purple-400' :
                      message.type === 'warning' ? 'text-amber-600 dark:text-terminal-amber' :
                      message.type === 'success' ? 'text-green-600 dark:text-green-400' :
                      'text-gray-600 dark:text-gray-400'
                    }`}>
                      {message.type}
                    </span>
                    <div className="flex-1">
                      <span className={`${getMessageStyle(message.type)} leading-relaxed text-base`}>
                        {message.content}
                      </span>
                      {message.category && (
                        <div className="mt-2">
                          <span className="inline-flex items-center px-3 py-1 rounded-md text-sm bg-gray-200 dark:bg-gray-800 text-gray-700 dark:text-gray-400 border border-gray-300 dark:border-gray-700">
                            <span className="mr-2">{getCategoryIcon(message.category)}</span>
                            {message.category}
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
                <div ref={messagesEndRef} />
              </div>
            )}
          </div>
          
          {/* Enhanced Terminal Input */}
          <div className="bg-gray-200 dark:bg-gray-800 px-6 py-4 border-t border-gray-300 dark:border-gray-700">
            <div className="flex items-center space-x-3 text-gray-700 dark:text-gray-400 text-base font-mono">
              <span className="text-green-600 dark:text-terminal-green">$</span>
              <span className="flex-1">
                {isPaused ? 'Terminal paused - click play to resume' : 'Monitoring AI agent activity...'}
              </span>
              {!isPaused && <span className="animate-pulse text-green-600 dark:text-terminal-green">|</span>}
              {isPaused && (
                <button
                  onClick={() => setIsPaused(false)}
                  className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 transition-colors px-3 py-1 bg-blue-100 dark:bg-blue-900/50 rounded border border-blue-300 dark:border-blue-800"
                >
                  Resume
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}