# Deploying MechConnect backend — step by step

This gets you: automatic build+test on every push, a Docker image published
to GitHub Container Registry, and a live public URL you can put on your
resume. Everything below is manual dashboard/CLI steps I can't click through
for you — but each one is short.

## 1. Push this project to GitHub

```
cd mechconnect-backend
git init
git add .
git commit -m "Add Docker + CI/CD"
git branch -M main
git remote add origin https://github.com/<your-username>/mechconnect-backend.git
git push -u origin main
```

The workflow in `.github/workflows/ci-cd.yml` runs automatically from here
on every push — check the "Actions" tab on your GitHub repo to watch it.

## 2. Test the Docker setup locally first (do this before deploying)

```
docker compose up --build
```

Visit `http://localhost:8080/actuator/health` — you should see
`{"status":"UP"}`. If this works locally, the same image will work in
production, because it's the exact same container.

## 3. Create a free Postgres database on Render

1. https://render.com → New → PostgreSQL → free tier.
2. Once created, open it and copy these four values from the dashboard:
   **Hostname**, **Port**, **Database**, **Username**, **Password**.
3. Build your JDBC URL from them:
   `jdbc:postgresql://<Hostname>:<Port>/<Database>`

## 4. Create the web service on Render

1. New → Web Service → connect your GitHub repo (or "Deploy an existing
   image" → `ghcr.io/<your-username>/mechconnect-backend:latest` once step 1
   has run at least once).
2. Environment: Docker.
3. Add these environment variables (Render's dashboard, not in code):
   - `SPRING_DATASOURCE_URL` = the JDBC URL from step 3
   - `SPRING_DATASOURCE_USERNAME` = the Postgres username from step 3
   - `SPRING_DATASOURCE_PASSWORD` = the Postgres password from step 3
   - `JWT_SECRET` = a fresh one — generate with `openssl rand -base64 48`,
     do **not** reuse the default that ships in this repo
   - `JPA_DDL_AUTO` = `update` (fine for now; switch to a real migration
     tool like Flyway before this holds anything you care about)
4. Deploy. Render gives you a public URL like
   `https://mechconnect-backend.onrender.com`.

## 5. (Optional) wire GitHub Actions → auto-redeploy

In Render, the web service settings have a **Deploy Hook** URL. Copy it,
then in GitHub: repo Settings → Secrets and variables → Actions → New
repository secret → name it `RENDER_DEPLOY_HOOK_URL`, paste the value. Now
every push to `main` that passes tests automatically redeploys.

## 6. Point the Flutter app at the live backend

In `lib/config/app_config.dart`, set:
```dart
static const String manualOverride = 'https://mechconnect-backend.onrender.com';
```
Rebuild the app. This is also literally your resume's "live demo" link.

## Honest caveat for free-tier Render

Render's free web services spin down after a period of inactivity and take
~30–60 seconds to wake up on the next request. That's fine for a demo link
on a resume, but mention it if a recruiter tests it and the first request
seems to hang — it's not broken, it's just waking up.
