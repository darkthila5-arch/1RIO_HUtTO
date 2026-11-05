# Deploy RIO X MD

Every option uses the same `Dockerfile` (Node bot + ffmpeg + Go call service). Push the repo to GitHub first (`.env` and `sessions/` are in `.gitignore`).
Variables are listed in `.env.example`. Minimum: `OWNER_NUMBER`, `WEB_SECRET`, `ADMIN_PASSWORD`.

| | Sessions survive redeploy? | Real call answering | Cost note |
|---|---|---|---|
| Render | Yes, with the disk in `render.yaml` | Yes | Starter plan or higher (disk) |
| Railway | Yes, with a Volume | Yes | Needs a Volume |
| VPS | Yes (Docker volume) | Yes | Cheapest for many numbers |
| Heroku | Only with `MONGO_URL` | No (needs a disk) | Use Basic, Eco dynos sleep |

## Render
1. New -> Blueprint -> pick the repo (`render.yaml` is read).
2. Set `ADMIN_PASSWORD`, `OWNER_NUMBER`, `PUBLIC_URL`. Deploy.

## Railway
1. New Project -> Deploy from GitHub repo (`railway.json` makes it build the Dockerfile).
2. Variables: `OWNER_NUMBER`, `WEB_SECRET`, `ADMIN_PASSWORD`, `SESSION_DIR=/data/sessions`, `TRUST_PROXY=1`.
3. Add a **Volume**, mount path `/data`.
4. Settings -> Networking -> Generate Domain. `PORT` is set by Railway.

## Heroku (container stack)
```bash
heroku create your-app-name --stack container
heroku config:set OWNER_NUMBER=94770000000 WEB_SECRET=$(openssl rand -hex 32) ADMIN_PASSWORD=change-me-long \
  MONGO_URL="mongodb+srv://..." TRUST_PROXY=1
git push heroku main
heroku ps:scale web=1 -a your-app-name
```
Heroku wipes files on every restart, so `MONGO_URL` (MongoDB Atlas, allow `0.0.0.0/0`) is required or every number must be re-linked. Optional: `heroku labs:enable runtime-dyno-metadata` so the site address is auto-detected.

## VPS (Ubuntu / Debian), Docker
```bash
git clone <your-repo> rio && cd rio
bash install-vps.sh        # installs Docker, creates .env with random secrets, builds and starts
```
Open `http://SERVER_IP:3000` (allow port 3000 in the firewall). Logs: `docker compose logs -f bot`. Update: `git pull && docker compose up -d --build`.

HTTPS with a domain (point the domain's A record to the server first): in `.env` set `DOMAIN=your.domain`, `BIND=127.0.0.1`, `TRUST_PROXY=1`, then
```bash
docker compose --profile https up -d --build
```

## VPS without Docker (pm2)
```bash
sudo apt install -y ffmpeg nodejs npm   # Node 20+
npm ci --omit=dev
cp .env.example .env && nano .env       # TRUST_PROXY=0 if no Nginx in front
npm i -g pm2 && pm2 start ecosystem.config.cjs && pm2 save && pm2 startup
```
Real call answering is not available here (the Go service is only built by the Dockerfile).

## Important
- Never run two copies with the same linked numbers (e.g. old + new service): they disconnect each other.
- `TRUST_PROXY=1` only when exactly one proxy is in front. On a plain VPS with port 3000 open use `0`, otherwise login lockouts can be dodged with a fake `X-Forwarded-For`.
