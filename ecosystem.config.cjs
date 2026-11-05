// VPS without Docker: npm ci --omit=dev && pm2 start ecosystem.config.cjs && pm2 save && pm2 startup
// Needs Node 20+, ffmpeg (apt install ffmpeg). The Go call-answering service is only built by the Dockerfile.
module.exports = {
  apps: [{
    name: 'rio-x-md',
    script: 'index.js',
    cwd: __dirname,
    max_memory_restart: '700M',
    kill_timeout: 8000,
    env: { NODE_ENV: 'production' }
  }]
};
