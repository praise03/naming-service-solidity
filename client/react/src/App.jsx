import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import Header from './components/Header'
import { MoralisProvider } from "react-moralis";
import { NotificationProvider } from "web3uikit";

import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <div>
      <MoralisProvider initializeOnMount={false}>
        <NotificationProvider>
            <Header />
        </NotificationProvider>
      </MoralisProvider>
      </div>
    </>
  )
}

export default App
