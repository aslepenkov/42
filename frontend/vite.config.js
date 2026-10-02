import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// /api and /health are proxied to the .NET backend, so no CORS setup is needed in dev.
const backend = process.env.BACKEND_URL ?? 'http://localhost:5000';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: { '/api': backend, '/health': backend },
  },
});
