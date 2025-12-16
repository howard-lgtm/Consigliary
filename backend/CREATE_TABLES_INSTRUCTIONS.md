# Quick Database Setup Instructions

## Execute Schema via Railway Dashboard

1. **Go to Railway Dashboard:**
   - URL: https://railway.app/project/453302b8-7e05-4d17-bf94-651434fed5eb
   
2. **Open PostgreSQL Database:**
   - Click on "Postgres" service (left sidebar)
   
3. **Open Query Tab:**
   - Click "Data" tab at the top
   - Click "Query" button
   
4. **Copy & Paste Schema:**
   - Open: `/Users/howardduffy/Desktop/Consigliary/backend/database/schema.sql`
   - Copy entire contents (248 lines)
   - Paste into Railway query editor
   
5. **Execute:**
   - Click "Run Query" or press Cmd+Enter
   - Wait for success message
   
6. **Verify Tables Created:**
   - You should see 9 new tables:
     - users
     - tracks
     - contributors
     - verifications
     - licenses
     - revenue_events
     - split_sheets
     - refresh_tokens
     - api_keys

## Alternative: Use psql Directly

If you prefer command line:

```bash
# Get DATABASE_URL from Railway
railway variables --service Postgres | grep DATABASE_URL

# Then connect and execute
psql "YOUR_DATABASE_URL_HERE" -f database/schema.sql
```

---

**Estimated Time:** 2 minutes
