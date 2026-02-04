# Create the GitHub repository and push

Follow these steps to create **ccam-lengau** on GitHub and push this folder as the repo.

## 1. Create the repo on GitHub

1. Go to [GitHub](https://github.com) and sign in.
2. Click **New repository** (or **+** → **New repository**).
3. Set:
   - **Repository name:** `ccam-lengau`
   - **Description:** `CCAM build and module for CHPC Lengau (Intel OneAPI)`
   - **Visibility:** Public (or Private if you prefer).
   - Do **not** add a README, .gitignore, or license (this folder already has them).
4. Click **Create repository**.

## 2. Push from your machine

In a terminal (PowerShell or Git Bash), from **this folder** (`ccam-lengau`):

```bash
cd ccam-lengau
git init
git add .
git commit -m "Initial commit: CCAM Lengau build script, module file, docs"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ccam-lengau.git
git push -u origin main
```

Replace **YOUR_USERNAME** with your GitHub username (e.g. `msovara`).

If you use SSH:

```bash
git remote add origin git@github.com:YOUR_USERNAME/ccam-lengau.git
git push -u origin main
```

## 3. Optional: GitHub CLI

If you have [GitHub CLI](https://cli.github.com/) installed:

```bash
cd ccam-lengau
git init
git add .
git commit -m "Initial commit: CCAM Lengau build script, module file, docs"
gh repo create ccam-lengau --public --source . --remote origin --push
```

This creates the repo and pushes in one go.

---

After pushing, the repo URL will be:

**https://github.com/YOUR_USERNAME/ccam-lengau**

You can share this link so others can clone the build script and module file for Lengau.
