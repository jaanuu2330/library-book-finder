# Library Book Finder

A beginner-friendly, responsive full-stack library catalog app for college students. Search and filter books, view availability, and create, edit, or delete book records. The frontend uses plain HTML, CSS, and JavaScript; the Express backend talks to a real Supabase PostgreSQL database.

## Features

- Responsive landing page and catalog cards.
- Search title, author, category, ISBN, and description.
- Filter by category and availability.
- CRUD through REST endpoints and Supabase database queries.
- Form validation, loading states, success/error notices, and empty states.
- Server-only Supabase credentials; RLS remains enabled.
- Example starter records are inserted by `database/schema.sql`.

## Technology stack

- Frontend: HTML5, CSS3, vanilla JavaScript, Fetch API
- Backend: Node.js, Express.js, CORS, dotenv
- Database: Supabase PostgreSQL
- Version control: Git and GitHub

## Prerequisites

Install a current LTS version of [Node.js](https://nodejs.org/) (npm is included), create a [Supabase](https://supabase.com/) account/project, and use a local static file server such as Visual Studio Code Live Server. Git is optional until the GitHub submission step.

## 1. Set up Supabase

1. Create a new project in Supabase and wait for provisioning to finish.
2. Open **SQL Editor** in the Supabase dashboard.
3. Open `database/schema.sql` from this project, copy its full contents into a new SQL query, and click **Run**.
4. Confirm that `public.books` exists in **Table Editor** and that the starter rows appear.
5. In the project settings/API area, copy the project URL and the server-side secret/service-role key. Supabase dashboard labels may vary by project/API-key version.

**Security note:** The service-role/secret key bypasses RLS. It belongs only in `backend/.env` on a trusted server; never paste it into `frontend/script.js`, HTML, GitHub, screenshots, or a public client. RLS is enabled and direct `anon`/`authenticated` table permissions are revoked. This educational demo API does not include user login or role-based admin access, so anyone who can reach the API can attempt catalog changes. Do not deploy it publicly without authentication, authorization, rate limiting, and appropriate monitoring. For production, prefer a least-privilege server-side design and review current Supabase key guidance.

## 2. Configure the backend

Open a terminal in the project directory, then run:

```bash
cd backend
```

Create a local environment file by copying the example:

**Windows Command Prompt**
```bat
copy .env.example .env
```

**PowerShell**
```powershell
Copy-Item .env.example .env
```

**macOS/Linux**
```bash
cp .env.example .env
```

Edit `backend/.env` and replace the placeholder values:

```dotenv
PORT=3000
SUPABASE_URL=https://YOUR-PROJECT-REF.supabase.co
SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVER_SIDE_SECRET_KEY
CORS_ORIGIN=http://localhost:5500,http://127.0.0.1:5500
```

Use your real project URL and server-only secret key locally. Do not commit `.env`.

## 3. Install and start the backend

Run all installation commands **inside the `backend` directory**:

```bash
npm install
```

The package file already declares all required dependencies. These additional commands are optional and are not required after a successful `npm install`; they are included for clarity if you want to install the named packages explicitly:

```bash
npm install express cors dotenv @supabase/supabase-js ws
npm install --save-dev nodemon
```

Start in development mode (auto-restarts on file changes):

```bash
npm run dev
```

Or start normally:

```bash
npm start
```

Expected startup message: `Library Book Finder API listening on http://localhost:3000`

Check API health in a browser at `http://localhost:3000/api/health`. A successful response indicates the database query worked. If it reports a database problem, confirm the schema and environment values.

## 4. Start the frontend

Keep the backend running. Open `frontend/index.html` with a local static server. In VS Code, install/use **Live Server**, right-click `frontend/index.html`, then choose **Open with Live Server**. The usual URL is `http://127.0.0.1:5500` or `http://localhost:5500`.

If your Live Server uses another port/origin, add that origin to `CORS_ORIGIN` in `backend/.env`, then restart the backend. The frontend defaults to `http://localhost:3000/api`. If the API runs elsewhere, set `window.LIBRARY_API_BASE` before `script.js` loads in `index.html`.

## 5. API endpoints

All routes are prefixed with `/api`. Successful list and item responses use a `data` field except where noted.

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/health` | Check API and database |
| GET | `/api/books` | List up to 500 books |
| GET | `/api/books?q=python` | Search title, author, and category |
| GET | `/api/books?category=Science` | Filter by category |
| GET | `/api/books?available=true` | Filter by availability |
| GET | `/api/books/:id` | Read one book by UUID |
| POST | `/api/books` | Create a book |
| PUT | `/api/books/:id` | Update a book |
| DELETE | `/api/books/:id` | Delete a book |

Example POST JSON:

```json
{
  "title": "Python Crash Course",
  "author": "Eric Matthes",
  "category": "Computer Science",
  "publication_year": 2019,
  "isbn": "9781593279288",
  "description": "A hands-on introduction to Python.",
  "available": true
}
```

Test the list endpoint in your browser: `http://localhost:3000/api/books`. To test write endpoints, use Postman, Thunder Client, or curl. Example (replace values as appropriate):

```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Demo Book\",\"author\":\"Demo Author\",\"category\":\"Science\",\"available\":true}"
```

Save the returned UUID if you want to test PUT and DELETE. Avoid testing DELETE on a record you need.

## 6. Git and GitHub submission

From the project root:

```bash
git init
git add .
git commit -m "Build Library Book Finder full-stack project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/library-book-finder.git
git push -u origin main
```

Create an empty GitHub repository first and replace `YOUR-USERNAME` with your own username. Check `git status` and make sure `.env` is not staged. Never commit credentials.

## 7. Common errors and troubleshooting

- **Missing Supabase configuration:** Ensure `backend/.env` exists, contains the correct variable names, and the server was restarted.
- **Database is not ready / table not found:** Run `database/schema.sql` in the correct Supabase project and check the project URL.
- **Invalid API key / permission error:** Use the correct server-side secret key locally. Never put it in the frontend.
- **CORS error:** Add the exact frontend origin (including scheme and port) to `CORS_ORIGIN`, separated by commas, and restart Node.
- **Cannot reach backend:** Check that `npm run dev` is running on port 3000 and visit `/api/health`.
- **Live Server displays a blank page:** Open `frontend/index.html` using Live Server, not the project folder alone; inspect browser DevTools Console.
- **Port already in use:** Change `PORT` in `.env` and update `API_BASE` in `frontend/script.js` or configure `window.LIBRARY_API_BASE`.
- **ISBN duplicate error:** The database requires unique non-null ISBN values. Leave ISBN blank if unknown.
- **Search punctuation issue:** Search is deliberately simple; search text is sanitized before building the Supabase filter.

## 8. Known limitations and remaining setup

- Supabase credentials are not included. Configure your own `backend/.env`.
- No authentication or user roles are implemented; catalog management is suitable only for a trusted local demo until access control is added.
- Search in the API is a simple title/author/category substring search. The frontend also filters the loaded catalog locally by ISBN and description.
- The API caps list responses at 500 rows; pagination is not included.
- No automated integration test can verify the remote Supabase connection without your project credentials.
- Use HTTPS, authentication, rate limiting, logging, and a carefully scoped server credential before deployment.

## 9. Three-minute project demonstration

1. Start the backend and open the frontend with Live Server.
2. Show the catalog and search for a title or author.
3. Filter by category and availability.
4. Add a sample book and show that it appears in the catalog.
5. Edit that book's details and save.
6. Delete the sample record and show the success message.
7. Open `/api/health` to demonstrate the API/database health check.
8. Explain that Express validates input and performs database queries using a server-only Supabase credential.

## 10. Beginner-friendly viva questions

**Q1. What is the purpose of this project?**  
A. It helps students search, filter, and manage a library book catalog through a web interface.

**Q2. What does Express.js do?**  
A. Express.js creates the backend server and API routes that receive requests from the frontend.

**Q3. What is Supabase?**  
A. Supabase is a backend platform that provides a PostgreSQL database and related services.

**Q4. What is CRUD?**  
A. CRUD means Create, Read, Update, and Delete—the four basic operations for managing records.

**Q5. Why should a secret key not be stored in frontend JavaScript?**  
A. Frontend files are visible to users. A secret key could be copied and misused, so it must stay on the backend.

## License

For educational and demonstration use. Review security settings before any public deployment.
