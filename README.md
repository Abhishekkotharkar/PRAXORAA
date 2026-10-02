# PRAXORAA

Premium responsive website for PRAXORAA, a digital development company founded by Abhishek Kotharkar.

## Run locally

Serve this folder with any static web server. For example:

```powershell
python -m http.server 4173
```

Then open `http://localhost:4173`.

## Google Sheets inquiries

The inquiry form is ready to send submissions to a Google Apps Script web app.

1. Open a Google Sheet and go to **Extensions > Apps Script**.
2. Paste the contents of `google-apps-script/Code.gs`.
3. Deploy it as a web app executed as you, with access for anyone.
4. Paste the deployed `/exec` URL into `GOOGLE_SHEETS_ENDPOINT` in `script.js`.

The script creates an `Inquiries` sheet tab and stores the submission time, contact details, project type, budget, and message.

## Automatic Git sync

Run `git-auto-sync-start.ps1` to watch this folder. Changes are committed and pushed to `main` after an 8-second pause. Use `git-auto-sync-stop.ps1` to stop the watcher.
The watcher runs locally in the background and writes activity to `.git-auto-sync.log`.
