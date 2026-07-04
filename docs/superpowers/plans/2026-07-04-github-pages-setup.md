# GitHub Pages — CI/CD Infraestrutura

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Otimizar o pipeline de deploy do Docusaurus para GitHub Pages com 404 customizado, CNAME, deploy preview e healthcheck.

**Architecture:** GitHub Actions workflow que faz build + deploy na main; deploy preview via artifact em PRs; arquivos estáticos na raiz do build.

**Tech Stack:** Docusaurus 3.10.1, GitHub Actions, PowerShell 5.1

## Global Constraints

- Todos os caminhos relativos a `C:\Dev\MinusFrameWork-Meta`
- Build do Docusaurus deve passar sem warnings
- Deploy deve ser idempotente
- Nenhum segredo pode ser commitado

---

### Task 1: Criar 404.html customizado

**Files:**
- Create: `static/404.html`

- [ ] **Step 1: Write 404.html**

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Página não encontrada — MinusFrameWork</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Inter', system-ui, -apple-system, sans-serif;
      background: #F8F4EF;
      color: #1B1B1E;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      margin: 0;
    }
    .container { text-align: center; padding: 2rem; max-width: 480px; }
    h1 { font-size: 4rem; font-weight: 800; color: #E07A5F; margin-bottom: 0.5rem; }
    h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem; }
    p { color: #666; margin-bottom: 2rem; line-height: 1.5; }
    .button {
      display: inline-block;
      padding: 0.75rem 2rem;
      background: #E07A5F;
      color: white;
      text-decoration: none;
      border-radius: 2rem;
      font-weight: 600;
      transition: background 0.2s;
    }
    .button:hover { background: #d96a4c; }
    @media (prefers-color-scheme: dark) {
      body { background: #1A1A1D; color: #E0E0E0; }
      p { color: #999; }
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>404</h1>
    <h2>Página não encontrada</h2>
    <p>A página que você procura não existe ou foi movida.</p>
    <a class="button" href="/minusframework/">Voltar ao início</a>
  </div>
</body>
</html>
```

- [ ] **Step 2: Verify file exists**

```powershell
Test-Path "C:\Dev\MinusFrameWork-Meta\static\404.html"
```
Expected: True

---

### Task 2: Adicionar CNAME

**Files:**
- Create: `static/CNAME` (se houver domínio, ou deixar placeholder comentado)

- [ ] **Step 1: Write CNAME (placeholder — descomentar quando tiver domínio)**

```
# Descomente quando tiver um domínio personalizado:
# minusframework.dev
```

---

### Task 3: Otimizar CI — cache, deploy preview, healthcheck

**Files:**
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: Existing CI workflow at `.github/workflows/ci.yml`
- Produces: CI workflow with cache, deploy preview on PRs, healthcheck post-deploy

- [ ] **Step 1: Read current CI**

```powershell
Get-Content "C:\Dev\MinusFrameWork-Meta\.github\workflows\ci.yml"
```

- [ ] **Step 2: Rewrite CI with cache + deploy preview + healthcheck**

```yaml
name: CI

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write
  pages: write
  id-token: write

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: npm
      - name: Install dependencies
        run: npm ci
      - name: Cache Docusaurus build
        id: cache-docusaurus
        uses: actions/cache@v4
        with:
          path: |
            .docusaurus
            build
          key: docusaurus-${{ hashFiles('docusaurus.config.ts', 'sidebars.ts', 'src/**/*', 'docs/**/*', 'static/**/*') }}
          restore-keys: |
            docusaurus-
      - name: Build Docusaurus
        run: npm run build
      - name: Upload build artifact (PR preview)
        if: github.event_name == 'pull_request'
        uses: actions/upload-pages-artifact@v3
        with:
          path: build
      - name: Deploy to GitHub Pages
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build
          cname: minusframework.dev
          full_commit_message: "docs: deploy ${{ github.sha }}"
      - name: Healthcheck post-deploy
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: |
          sleep 10
          curl -s -o /dev/null -w "%{http_code}" "https://gabrielferreiramendes.github.io/minusframework/" | grep 200
          echo "Site is live and returning 200"

  deploy-preview:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: npm
      - run: npm ci
      - run: npm run build
      - name: Deploy preview to GitHub Pages (PR)
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build
          destination_dir: pr-${{ github.event.number }}
      - name: Comment PR with preview link
        uses: actions/github-script@v7
        with:
          script: |
            const prNumber = context.issue.number;
            const previewUrl = `https://gabrielferreiramendes.github.io/minusframework/pr-${prNumber}/`;
            github.rest.issues.createComment({
              issue_number: prNumber,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Preview disponível\n\nAcesse: ${previewUrl}\n\n> Este preview é atualizado a cada push no PR.`
            });

  wiki:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0
      - name: Deploy Wiki
        shell: pwsh
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          if (Test-Path "deploy-wiki.ps1") {
            ./deploy-wiki.ps1 -Token "$env:GH_TOKEN"
          }

  release-sync:
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0
      - name: Sync releases across submodules
        env:
          TOKEN: ${{ secrets.GH_PAT }}
        run: |
          $tag = "${{ github.ref_name }}"
          pwsh ./release-sync.ps1 -Version $tag -Token "$env:TOKEN"
```

- [ ] **Step 3: Verify Docusaurus build still passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS, zero warnings.

---

### Task 4: Adicionar badge de status no README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read current README**

```powershell
Get-Content "C:\Dev\MinusFrameWork-Meta\README.md" -TotalCount 20
```

- [ ] **Step 2: Add workflow status badge at top**

Add right after the title:

```markdown
[![CI](https://github.com/GabrielFerreiraMendes/minusframework/actions/workflows/ci.yml/badge.svg)](https://github.com/GabrielFerreiraMendes/minusframework/actions/workflows/ci.yml)
```
