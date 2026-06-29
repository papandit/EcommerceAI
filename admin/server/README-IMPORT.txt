SERVER-SIDE DATA IMPORT — run these on the live server
=====================================================================

This bundle moves all of your local catalog data + images onto the live site.
It uses the server's OWN database connection (the MONGODB_URI already in the
backend's .env), so you do not have to type the DB password anywhere.

1. Upload/extract this bundle INSIDE the backend folder on the server, i.e.:
       admin/server/import-data.js
       admin/server/data-export/      (the .json files)
       admin/server/uploads/          (merge with the existing uploads folder)

2. SSH into the server and go to the backend folder:
       cd /path/to/admin/server

3. Dry run first (writes nothing — just shows the counts):
       node import-data.js

4. If the counts look right, do the real import (replaces the collections):
       node import-data.js --yes

5. Verify:
       curl https://ecommai.onewebmart.cloud/api/products
   and open https://ecommai.onewebmart.cloud/ in a browser.

Notes
- It full-replaces each collection (the live DB only had placeholder data).
- The "users" collection includes the admin login  admin@ecom.com / admin123.
- Image URLs were already rewritten to https://ecommai.onewebmart.cloud/uploads/...
  so the uploads/ files MUST be in admin/server/uploads/ for images to show.
- node_modules must exist in admin/server (mongoose, bson, dotenv). If the server
  backend already runs, they're there.
