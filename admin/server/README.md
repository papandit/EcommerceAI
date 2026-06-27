# E-commerce Backend (Node/Express + MongoDB)

Replaces Firebase Firestore + Storage for the admin panel and storefront.
Firebase is kept **only** to verify Google Sign-In ID tokens (storefront phase).

## Run (local dev)
```bash
cd backend
cp .env.example .env        # adjust if needed (defaults work with local MongoDB)
npm install
npm run seed                # creates admin: admin@ecom.com / admin123
npm run dev                 # nodemon, http://localhost:4000
# or: npm start
```
Requires MongoDB running locally (default `mongodb://127.0.0.1:27017/ecom`).

Health check: `GET http://localhost:4000/api/health`

## Response envelope
```json
{ "success": true, "message": "...", "data": ... }
```
Documents include `id` (string, from Mongo `_id`) and `Id` (alias), plus
`CreatedAt`/`UpdatedAt`. Field names match the old Firestore docs (capitalized,
e.g. `Title`, `Price`, `Thumbnail`) so the Flutter models parse responses with
minimal changes.

## API
- **Auth:** `POST /api/auth/register | login | google-login | refresh-token | logout`, `GET /api/auth/me`
- **Products:** `GET /api/products` (`?page&limit&q&categoryId&brandId&minPrice&maxPrice&featured&sort&paged`),
  `GET/POST/PUT/DELETE /api/products[/:id]`
- **Catalog:** `/api/categories`, `/api/banners`, `/api/brands`, `/api/departments`, `/api/coupons` — full CRUD
- **Orders:** `/api/orders` (list/update/delete = admin; create = any auth user)
- **Reviews:** `POST /api/reviews` (public), list/manage = admin
- **Per-user:** `/api/carts`, `/api/wishlists`, `/api/addresses` (auth)
- **Singletons:** `GET/PUT /api/settings`, `GET/PUT /api/luxeedit`
- **Uploads:** `POST /api/upload/:type` (`product|banner|category|profile|brand`),
  multipart field `file` (or `image`) → `{ url }`. Files compressed to webp and
  served at `/uploads/<type>/<file>`.

Writes require `Authorization: Bearer <jwt>`; admin-only writes require an admin token.

## Google Sign-In (storefront phase)
`POST /api/auth/google-login { idToken }` verifies the Firebase ID token via
`firebase-admin` and returns our JWT. Needs a service account: set
`GOOGLE_APPLICATION_CREDENTIALS=./serviceAccount.json` (or `FIREBASE_SERVICE_ACCOUNT`)
and `FIREBASE_PROJECT_ID`. Until then the endpoint returns 501.

## Deploy (Hostinger — final phase)
Node + PM2 + Nginx reverse proxy + SSL; point `BASE_URL` and the Flutter
`ApiClient` base URL at the domain; MongoDB on the VPS or Atlas.
