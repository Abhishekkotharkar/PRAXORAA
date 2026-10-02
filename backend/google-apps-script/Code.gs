const SHEET_NAME = "Inquiries";
const HEADERS = [
  "Submitted at",
  "Name",
  "Email",
  "Phone",
  "Company",
  "Project type",
  "Budget range",
  "Message"
];

function doGet() {
  return ContentService
    .createTextOutput("PRAXORAA inquiry endpoint is running.")
    .setMimeType(ContentService.MimeType.TEXT);
}

function doPost(event) {
  const lock = LockService.getScriptLock();
  lock.waitLock(10000);

  try {
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = spreadsheet.getSheetByName(SHEET_NAME) || spreadsheet.insertSheet(SHEET_NAME);

    if (sheet.getLastRow() === 0) {
      sheet.appendRow(HEADERS);
      sheet.setFrozenRows(1);
    }

    const params = event && event.parameter ? event.parameter : {};
    sheet.appendRow([
      new Date(),
      safeCell(params.name),
      safeCell(params.email),
      safeCell(params.phone),
      safeCell(params.company),
      safeCell(params.projectType),
      safeCell(params.budget),
      safeCell(params.message)
    ]);

    return ContentService
      .createTextOutput(JSON.stringify({ ok: true }))
      .setMimeType(ContentService.MimeType.JSON);
  } finally {
    lock.releaseLock();
  }
}

function safeCell(value) {
  const text = value == null ? "" : String(value).trim();

  // Prevent submitted text from being interpreted as a spreadsheet formula.
  return /^[=+\-@]/.test(text) ? "'" + text : text;
}
