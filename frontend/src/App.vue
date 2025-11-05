<template>
  <div class="app-wrapper">
    <Aurora
      :colorStops="['#676cff', '#171D22', '#676cff']"
      :amplitude="1.5"
      :blend="0.8"
      :speed="0.8"
      :intensity="0.6"
      class="aurora-background"
    />
    <div class="container">
      <h1>WebSocket Chat</h1>
      <h2>Status: {{ status }}</h2>

      <div v-if="!username" class="name-prompt">
        <input
          v-model="nameInput"
          @keyup.enter="setUsername"
          placeholder="Enter your name..."
          class="input"
        />
        <button @click="setUsername" class="button">Join Chat</button>
      </div>

      <div v-else>
        <div class="current-user">Chatting as: {{ username }}</div>

        <div class="chat-box">
          <div
            v-for="(msg, i) in messages"
            :key="i"
            :class="{
              'system-message': msg.type === 'system',
              'message': msg.type === 'message' && !msg.isOwn,
              'message-own': msg.type === 'message' && msg.isOwn
            }"
          >
            {{ msg.text }}
          </div>
        </div>

        <input
          v-model="input"
          @keyup.enter="sendMessage"
          placeholder="Type a message..."
          class="input"
        />
        <button @click="sendMessage" class="button">Send</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Aurora from './components/Aurora.vue'

interface Message {
  type: 'message' | 'system'
  text: string
  isOwn?: boolean
}

const messages = ref<Message[]>([])
const input = ref('')
const username = ref('')
const nameInput = ref('')
var status = ref('Disconnected')
let ws: WebSocket

onMounted(() => {
  connect()
})

function connect() {
  ws = new WebSocket('ws://localhost:9000')

  ws.onopen = () => {
    console.log('Connected to server')
    status.value = 'Connected'
  }
  ws.onmessage = async (event) => {
    const text = typeof event.data === 'string' ? event.data : await event.data.text()
    const data = JSON.parse(text)

    if (data.type === 'join') {
      messages.value.push({
        type: 'system',
        text: `${data.username} joined the chat`,
      })
    } else if (data.type === 'leave') {
      messages.value.push({
        type: 'system',
        text: `${data.username} left the chat`,
      })
    } else if (data.type === 'message') {
      messages.value.push({
        type: 'message',
        text: `${data.username}: ${data.text}`,
        isOwn: data.username === username.value,
      })
    }
  }
  ws.onclose = () => {
    console.log('Disconnected. Reconnecting...')
    status.value = 'Disconnected'
    setTimeout(connect, 1000)
  }
}

const setUsername = () => {
  const name = nameInput.value.trim()
  if (!name) return
  username.value = name

  // Send join message to server
  ws.send(
    JSON.stringify({
      type: 'join',
      username: name,
    }),
  )
}

const sendMessage = () => {
  const text = input.value.trim()
  if (!text) return

  ws.send(
    JSON.stringify({
      type: 'message',
      username: username.value,
      text: text,
    }),
  )
  input.value = ''
}
</script>

<style scoped>
.app-wrapper {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: auto;
}

.aurora-background {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  pointer-events: none;
}

.container {
  max-width: 400px;
  margin: 40px auto;
  font-family: sans-serif;
  text-align: center;
  position: relative;
  z-index: 1;
}

h1 {
  color: #ffffff;
}

h2 {
  color: #676cff;
  font-size: 1.2rem;
}

.name-prompt {
  margin-top: 20px;
}

.current-user {
  font-weight: bold;
  margin-bottom: 10px;
  color: #676cff;
}

.chat-box {
  background: rgba(23, 29, 34, 0.85);
  border: 1px solid rgba(166, 103, 255, 0.3);
  border-radius: 8px;
  height: 250px;
  overflow-y: auto;
  margin-bottom: 10px;
  padding: 10px;
  text-align: left;
  backdrop-filter: blur(10px);
}

.input {
  width: 70%;
  padding: 8px;
  background: rgba(23, 29, 34, 0.8);
  border: 1px solid rgba(204, 103, 255, 0.3);
  border-radius: 4px;
  color: #ffffff;
  outline: none;
}

.input::placeholder {
  color: rgba(255, 255, 255, 0.5);
}

.input:focus {
  border-color: #676cff;
}

.button {
  padding: 8px 12px;
  margin-left: 5px;
  background: rgba(133, 103, 255, 0.2);
  border: 1px solid #676cff;
  border-radius: 4px;
  color: #676cff;
  cursor: pointer;
}

.button:hover {
  background: rgba(184, 103, 255, 0.3);
}

.message {
  margin-bottom: 4px;
  color: #ffffff;
  background: rgba(255, 255, 255, 0.1);
  padding: 4px 8px;
  border-radius: 4px;
  border-left: 3px solid rgba(255, 255, 255, 0.3);
}

.message-own {
  margin-bottom: 4px;
  color: #ffffff;
  background: rgba(103, 108, 255, 0.2);
  padding: 4px 8px;
  border-radius: 4px;
  border-left: 3px solid #676cff;
}

.system-message {
  margin-bottom: 4px;
  color: #676cff;
  font-style: italic;
  text-align: center;
  opacity: 0.8;
}
</style>
