import React, { useState } from 'react'
import { X, Info } from 'lucide-react'

export function DemoNotice() {
  const [isVisible, setIsVisible] = useState(true)

  if (!isVisible) return null

  return (
    <div className="bg-amber-900/50 border border-amber-800 text-amber-200 px-4 py-3 relative">
      <div className="flex items-center justify-between max-w-7xl mx-auto">
        <div className="flex items-center space-x-3">
          <Info className="h-5 w-5 text-amber-400 flex-shrink-0" />
          <div className="text-sm">
            <strong>Demo Mode:</strong> This is a demonstration application. 
            No emails are sent, data is stored in memory only, and some features are simulated.
          </div>
        </div>
        <button
          onClick={() => setIsVisible(false)}
          className="text-amber-400 hover:text-amber-300 transition-colors"
        >
          <X className="h-5 w-5" />
        </button>
      </div>
    </div>
  )
}