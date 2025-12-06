# 🚨 CRITICAL: Server Configuration Guide

## Upload assetlinks.json to Enable Android App Links

**Priority**: HIGH - Required for external QR scanners to open the app

---

## File Location

📁 **Local file**: `/Users/jatinjaiswal/Documents/Work/Flutter/Bug Battlers/creatoo_app/android/app/assetlinks.json`

🌐 **Server destination**: `https://api.tapbill.in/.well-known/assetlinks.json`

---

## Upload Instructions

### 1. Access your server
SSH or FTP into `api.tapbill.in`

### 2. Create directory
```bash
mkdir -p /path/to/webroot/.well-known
```

### 3. Upload file
Copy `assetlinks.json` to `/.well-known/` directory

### 4. Set permissions
```bash
chmod 644 /path/to/webroot/.well-known/assetlinks.json
```

### 5. Configure web server

**For Nginx**, add to your server block:
```nginx
location /.well-known/assetlinks.json {
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
}
```

**For Apache**, create/update `.htaccess`:
```apache
<Files "assetlinks.json">
    Header set Content-Type "application/json"
    Header set Access-Control-Allow-Origin "*"
</FilesMatch>
```

### 6. Verify upload
Test URL in browser or terminal:

```bash
curl -I https://api.tapbill.in/.well-known/assetlinks.json
```

Should return:
- Status: `200 OK`
- Content-Type: `application/json`

```bash
curl https://api.tapbill.in/.well-known/assetlinks.json
```

Should return the JSON content.

---

## File Contents

The file contains:
- Package name: `com.creatoo.app`
- SHA-256 fingerprint: `08:BC:B4:A2:73:AD:4E:B6:D1:E8:98:7E:F5:98:1A:AC:B9:FE:C8:69:68:B5:DA:76:69:CA:CA:98:8E:27:38:56`
- Permission: `delegate_permission/common.handle_all_urls`

---

## Testing After Upload

1. **Clear app data** on test device:
   ```bash
   adb shell pm clear com.creatoo.app
   ```

2. **Reinstall app**:
   ```bash
   flutter install
   ```

3. **Check verification status**:
   ```bash
   adb shell pm get-app-links com.creatoo.app
   ```
   
   Should show: `verified` status for `api.tapbill.in`

4. **Test deep link**:
   ```bash
   adb shell am start -W -a android.intent.action.VIEW \
     -d "https://api.tapbill.in/api/scan?businessId=123" \
     com.creatoo.app
   ```

5. **Test with QR scanner**: Scan a business QR code with phone camera

---

## Troubleshooting

### Issue: URL returns 404
- Check file path is correct: `/.well-known/assetlinks.json`
- Verify file uploaded to correct web root directory
- Check web server configuration

### Issue: Wrong content type
- Configure web server to serve JSON with correct MIME type
- Add explicit header in nginx/apache config

### Issue: Verification fails
- Ensure SHA-256 fingerprint matches your app's signing key
- Check package name is exactly `com.creatoo.app`
- Verify JSON syntax is valid (no trailing commas, proper formatting)

---

## Quick Verification Checklist

- [ ] File uploaded to `/.well-known/assetlinks.json`
- [ ] URL accessible: `https://api.tapbill.in/.well-known/assetlinks.json`
- [ ] Returns HTTP 200
- [ ] Content-Type is `application/json`
- [ ] JSON content is valid
- [ ] App reinstalled to trigger re-verification
- [ ] Deep link test passes
- [ ] External QR scanner opens app automatically

---

## Need Help?

If upload fails or verification doesn't work:
1. Check server logs for errors
2. Verify domain SSL certificate is valid
3. Test with Google's validation tool: https://developers.google.com/digital-asset-links/tools/generator
4. Contact your server administrator for web server configuration
