# Contributing to Laravel Docker Starter Kit

Thank you for considering a contribution! 🎉

Every merged PR to this repo counts toward the **🌍 Open Sourcerer** GitHub achievement — your effort is doubly rewarded.

---

## 🚀 Quick Contribution

### Fix a typo / improve docs (5 minutes)

```bash
# 1. Fork on GitHub, then:
git clone https://github.com/YOUR_USERNAME/docker-laravel-starter.git
cd docker-laravel-starter

# 2. Create a branch
git checkout -b fix/improve-readme

# 3. Make your change
# ...

# 4. Commit (add Co-authored-by if pair programming)
git commit -m "docs: improve README example for PostgreSQL setup

Co-authored-by: Your Pair <pair@users.noreply.github.com>"

# 5. Push and open PR
git push origin fix/improve-readme
gh pr create --fill
```

---

## 💡 Good First Issues

Look for these labels in [Issues](https://github.com/serwin35/docker-laravel-starter/issues):

- `good first issue` — beginner-friendly
- `documentation` — docs improvements
- `help wanted` — maintainer needs help

---

## 📋 Types of Contributions We Welcome

| Type | Examples |
|---|---|
| 📖 Documentation | Fix typos, improve examples, add missing sections |
| 🐛 Bug fixes | Fix broken config, incorrect commands |
| ✨ New features | New PHP extensions, additional services, new env configs |
| 🔧 DX improvements | Better Makefile targets, improved error messages |
| 🌐 Translations | Translate README to other languages |
| 🧪 Tests | Additional CI test scenarios |

---

## 📝 Pull Request Guidelines

### Branch naming

```
feat/add-redis-cluster
fix/nginx-php-fpm-timeout
docs/improve-deployment-guide
chore/update-php-84
```

### Commit message format

```
type(scope): short description

Optional longer explanation of why, not what.

Co-authored-by: Name <name@users.noreply.github.com>
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`

### PR checklist

- [ ] Branch is up to date with `main`
- [ ] Description explains **what** and **why**
- [ ] No secrets or credentials in commits
- [ ] Tested locally with `docker compose up`
- [ ] `.env.example` updated if new env vars added

---

## 🛠️ Local Development Setup

```bash
cp .env.example .env
make setup DB=mysql      # or DB=pgsql
```

Test your changes:

```bash
make ps       # verify containers are healthy
make test     # run PHPUnit tests (if applicable)
```

---

## 🎖️ Achievement Bonus

When your PR is merged here:
- **🌍 Open Sourcerer** — this repo uses GitHub Actions ✅
- **🦈 Pull Shark** — merged PR count increases ✅
- Add `Co-authored-by:` → **👥 Pair Extraordinaire** ✅

---

## 💬 Questions?

Open a [Discussion](https://github.com/serwin35/docker-laravel-starter/discussions) — we prefer discussions over issues for questions.

---

Thank you for contributing! 🙏
