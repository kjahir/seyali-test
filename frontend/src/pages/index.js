import { useEffect, useState } from 'react'
import Head from 'next/head'
import styles from '../styles/Home.module.css'

export default function Home() {
  const [apiStatus, setApiStatus] = useState('checking...')
  const [apiMessage, setApiMessage] = useState('')
  const [backendStatus, setBackendStatus] = useState(null)

  useEffect(() => {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:10000'
    
    // Check API health
    fetch(`${apiUrl}/health`)
      .then(res => res.json())
      .then(data => {
        setApiStatus('✅ Connected')
        console.log('API Health:', data)
      })
      .catch(err => {
        setApiStatus('❌ Disconnected')
        console.error('API Error:', err)
      })

    // Get API message
    fetch(`${apiUrl}/api/hello`)
      .then(res => res.json())
      .then(data => setApiMessage(data.message))
      .catch(err => console.error('API Error:', err))

    // Get backend status
    fetch(`${apiUrl}/api/status`)
      .then(res => res.json())
      .then(data => setBackendStatus(data))
      .catch(err => console.error('Status Error:', err))
  }, [])

  return (
    <div className={styles.container}>
      <Head>
        <title>Seyali - Home</title>
        <meta name="description" content="Seyali application" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>
          Welcome to <span className={styles.highlight}>Seyali</span>
        </h1>

        <div className={styles.status}>
          <h3>System Status</h3>
          <p><strong>Backend:</strong> {apiStatus}</p>
          {apiMessage && <p><strong>Message:</strong> {apiMessage}</p>}
          {backendStatus && (
            <div style={{ marginTop: '10px', fontSize: '14px' }}>
              <p>Backend: {backendStatus.backend}</p>
              <p>Database: {backendStatus.database}</p>
              <p>Redis: {backendStatus.redis}</p>
            </div>
          )}
          <p style={{ marginTop: '10px', fontSize: '12px', color: '#666' }}>
            API URL: {process.env.NEXT_PUBLIC_API_URL || 'http://localhost:10000'}
          </p>
        </div>

        <div className={styles.grid}>
          <div className={styles.card}>
            <h2>📚 Documentation</h2>
            <p>Learn about Seyali features and API</p>
          </div>

          <div className={styles.card}>
            <h2>📊 Dashboard</h2>
            <p>Access your dashboard</p>
          </div>

          <div className={styles.card}>
            <h2>⚙️ Settings</h2>
            <p>Configure your application</p>
          </div>

          <div className={styles.card}>
            <h2>💬 Support</h2>
            <p>Get help from our team</p>
          </div>
        </div>
      </main>

      <footer className={styles.footer}>
        <p>Powered by Seyali © 2024</p>
      </footer>
    </div>
  )
}
