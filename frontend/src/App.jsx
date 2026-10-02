import { useEffect, useState } from 'react';

// Empty in dev (Vite proxy); set VITE_API_BASE_URL for production builds.
const API = import.meta.env.VITE_API_BASE_URL ?? '';

async function getJson(path) {
  const res = await fetch(API + path);
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
  return res.json();
}

export default function App() {
  const [name, setName] = useState('');
  const [health, setHealth] = useState('checking…');
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    getJson('/health')
      .then((h) => setHealth(h.status))
      .catch(() => setHealth('backend unreachable'));
  }, []);

  async function greet(e) {
    e.preventDefault();
    setError('');
    try {
      const data = await getJson(`/api/hello?name=${encodeURIComponent(name)}`);
      setMessage(data.message);
    } catch (err) {
      setMessage('');
      setError(err.message);
    }
  }

  return (
    <main style={{ fontFamily: 'sans-serif', maxWidth: 480, margin: '4rem auto' }}>
      <h1>42</h1>
      <p>Backend: <strong>{health}</strong></p>
      <form onSubmit={greet}>
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Your name" />
        <button type="submit">Greet</button>
      </form>
      {message && <p>{message}</p>}
      {error && <p style={{ color: 'crimson' }}>{error}</p>}
    </main>
  );
}
