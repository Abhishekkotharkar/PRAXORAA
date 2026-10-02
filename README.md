# PRAXORAA

Premium responsive website for PRAXORAA, a digital development company founded by Abhishek Kotharkar.

## Run locally

Serve this folder with any static web server. For example:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-local.ps1
```

Then open `http://localhost:4173`.

## Google Sheets inquiries

The inquiry form is ready to send submissions to a Google Apps Script web app.

1. Open a Google Sheet and go to **Extensions > Apps Script**.
2. Paste the contents of `backend/google-apps-script/Code.gs`.
3. Deploy it as a web app executed as you, with access for anyone.
4. Paste the deployed `/exec` URL into `GOOGLE_SHEETS_ENDPOINT` in `frontend/script.js`.

The script creates an `Inquiries` sheet tab and stores the submission time, contact details, project type, budget, and message.

## Automatic Git sync

Run `scripts/git-auto-sync-start.ps1` to watch this folder. Changes are committed and pushed to the current branch after an 8-second pause. Use `scripts/git-auto-sync-stop.ps1` to stop the watcher.
The watcher runs locally in the background and writes activity to `.git-auto-sync.log`.

## Custom domain: praxiraa.com

GitHub Pages must be enabled from the repository's **Settings > Pages** page with **GitHub Actions** selected as the source. Enter `praxiraa.com` under **Custom domain**.

At the domain registrar, add these records:

```text
@      A       185.199.108.153
@      A       185.199.109.153
@      A       185.199.110.153
@      A       185.199.111.153
www    CNAME   Abhishekkotharkar.github.io
```

After DNS propagation, enable **Enforce HTTPS** in GitHub Pages. DNS and HTTPS changes can take time to become available.
