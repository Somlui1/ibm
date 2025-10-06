import requests

# ===============================
# ตัวแปรตั้งค่า
# ===============================
USERNAME = "db2aapico"
PASSWORD = "db2aapico"
HOST = "10.10.10.70"
PORT = "9569"

LOGIN_URL = f"https://{HOST}:{PORT}/srm/j_security_check"
DASHBOARD_URL = f"https://{HOST}:{PORT}/srm/REST/api/v1/StorageSystems/23080/RemoteReplication"

# ===============================
# สร้าง session (แทน wget เก็บ cookies)
# ===============================
session = requests.Session()
session.verify = False   # ข้าม SSL certificate verification (เหมือน --no-check-certificate)

# ===============================
# ส่ง POST login
# ===============================
login_data = {
    "j_username": USERNAME,
    "j_password": PASSWORD
}

resp = session.post(LOGIN_URL, data=login_data)

if resp.status_code == 200:
    print("✅ Login success")
else:
    print(f"❌ Login failed: {resp.status_code}")
    exit(1)

# ===============================
# เรียกหน้า dashboard / API
# ===============================
resp2 = session.get(DASHBOARD_URL)

if resp2.status_code == 200:
    with open("dashboard.json", "wb") as f:
        f.write(resp2.content)
    print("📄 Dashboard/API response saved to dashboard.json")
else:
    print(f"❌ Failed to get dashboard: {resp2.status_code}")
