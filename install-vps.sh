#!/usr/bin/env bash
# One-command VPS setup (Ubuntu / Debian). Run inside the project folder:  bash install-vps.sh
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v docker >/dev/null 2>&1; then
  echo ">> Installing Docker"
  curl -fsSL https://get.docker.com | sh
fi

if [ ! -f .env ]; then
  cp .env.example .env
  rnd() { openssl rand -hex 16; }
  read -rp "Owner number (country code, digits only, e.g. 94770000000): " OWNER
  ADMINPW="$(rnd)"
  sed -i "s|^OWNER_NUMBER=.*|OWNER_NUMBER=${OWNER}|" .env
  sed -i "s|^WEB_SECRET=.*|WEB_SECRET=$(openssl rand -hex 32)|" .env
  sed -i "s|^PAIRING_API_KEY=.*|PAIRING_API_KEY=$(rnd)|" .env
  sed -i "s|^ADMIN_PASSWORD=.*|ADMIN_PASSWORD=${ADMINPW}|" .env
  sed -i "s|^TRUST_PROXY=.*|TRUST_PROXY=0|" .env
  echo ">> .env created. /admin login:  admin / ${ADMINPW}   (saved in .env)"
fi

docker compose up -d --build
IP="$(curl -fsS https://api.ipify.org 2>/dev/null || echo YOUR_SERVER_IP)"
echo ">> Running: http://${IP}:3000   (open port 3000 in your firewall / provider panel)"
echo ">> Logs: docker compose logs -f bot"
