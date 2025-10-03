#!/bin/bash

# ===============================
# ตัวแปรตั้งค่า
# ===============================
USERNAME="db2aapico"
PASSWORD="db2aapico"
HOST="10.10.10.70"
PORT="9569"

LOGIN_URL="https://$HOST:$PORT/srm/j_security_check"

COOKIE_FILE="cookies.txt"
LOGIN_HTML="j_security_check.html"
DASHBOARD_HTML="dashboard.html"

# ===============================
# ส่ง POST login และเก็บ cookie
# ===============================
wget --quiet \
     --post-data "j_username=$USERNAME&j_password=$PASSWORD" \
     --no-check-certificate \
     --keep-session-cookies \
     --save-cookies "$COOKIE_FILE" \
     --output-document="$LOGIN_HTML" \
     "$LOGIN_URL"

echo "Login complete. Cookies saved to $COOKIE_FILE and response saved to $LOGIN_HTML"

# ===============================
# เรียกหน้า dashboard / API ด้วย cookies
# ===============================
wget --quiet \
     --no-check-certificate \
     --load-cookies "$COOKIE_FILE" \
     --output-document "$DASHBOARD_HTML" \
     "https://$HOST:$PORT/srm/REST/api/v1/StorageSystems/57909/Volumes"

echo "Dashboard/API page saved to $DASHBOARD_HTML"
