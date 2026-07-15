<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="static/img/logo-icon-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="static/img/logo-icon.svg">
    <img src="static/img/logo-icon.svg" alt="MinusFrameWork" width="64" />
  </picture>
</p>

<h1 align="center">MinusFrameWork</h1>

<p align="center">
  Framework Delphi moderno, modular e corporativo � ORM, Migrator, Mensageria, Feature Flags, Telemetria e IA
</p>

<p align="center">
  <a href="https://github.com/minusframework/minusframework/actions/workflows/ci.yml"><img src="https://github.com/minusframework/minusframework/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="https://gabrielferreiramendes.github.io/minusframework/"><img src="https://img.shields.io/badge/docs-online-blue" alt="Docs" /></a>
  <a href="https://github.com/minusframework/minusframework/blob/main/LICENSE"><img src="https://img.shields.io/badge/licen%C3%A7a-MIT%20%7C%20Pro%20%7C%20Enterprise-blue" alt="License" /></a>
</p>

---

## Sobre

**MinusFrameWork** � um framework Delphi focado em produtividade corporativa, seguindo princ�pios de Clean Architecture, SOLID e Object Calisthenics. Oferece uma su�te modular de componentes que v�o do ORM � intelig�ncia artificial, com licenciamento flex�vel (Free/Pro/Enterprise).

Este reposit�rio � o **meta-reposit�rio oficial**, contendo a documenta��o, site, CI/CD, instalador, scripts de automa��o e arquivos de licenciamento.

## Documenta��o

A documenta��o completa est� dispon�vel em:

- ?? **Site publicado**: [gabrielferreiramendes.github.io/minusframework](https://gabrielferreiramendes.github.io/minusframework/)
- ?? **Docs locais**: `./docs/` (formato Docusaurus)

### Desenvolvimento local

```bash
npm ci
npm start
```

Acesse `http://localhost:3000/minusframework/`. Para build de produ��o:

```bash
npm run build
npx docusaurus serve
```

## M�dulos

| M�dulo | Categoria | Licen�a | Descri��o |
|--------|-----------|---------|-----------|
| MinusORM | ORM | Free | ORM com RTTI, queries fluentes, Unit of Work e Change Tracking |
| MinusMigrator | Migrator | Free | Migra��o versionada de schema via CLI, GUI e DLL |
| MinusCLI | CLI | Free | Scaffolding de entidades, APIs e projetos |
| MinusFeatureFlags | Feature Flags | Pro | Feature flags com rollout percentual, A/B testing, SSE e REST API |
| MinusMessaging | Mensageria | Pro | Message bus multi-provider com retry, circuit breaker, sagas e outbox |
| MinusExtensions | Extens�es | Pro | Integra��es prontas para Horse, JWT e bibliotecas de terceiros |
| MinusTelemetry | Telemetria | Enterprise | Tracing e logging estruturado no padr�o OpenTelemetry |
| MinusAI | Intelig�ncia Artificial | Enterprise | Agentes inteligentes e servidor MCP para Delphi |

## Estrutura do reposit�rio

```
MinusFrameWork-Meta/
+-- docs/              # Documenta��o (Docusaurus)
+-- src/               # C�digo-fonte do site (React)
+-- i18n/              # Tradu��es (pt-BR, en)
+-- static/            # Assets est�ticos (imagens, 404, robots)
+-- .github/workflows/ # CI/CD (docs, wiki, release)
+-- site/              # Site do instalador
+-- AI/                # M�dulo de IA
+-- Cli/               # M�dulo CLI
+-- Core/              # N�cleo do framework
+-- FeatureFlags/      # M�dulo de feature flags
+-- Messaging/         # M�dulo de mensageria
+-- Migrator/          # M�dulo de migra��o
+-- ORM/               # M�dulo ORM
+-- Telemetry/         # M�dulo de telemetria
+-- Extensions/        # Extens�es para terceiros
+-- Installer/         # Instalador Inno Setup
+-- license-server/    # Servidor de licenciamento
+-- .superpowers/      # Planos e specs de design
+-- scripts/           # Scripts de automa��o (release, CI, wiki, installer, license)
```

## Planos e licenciamento

| Plano | Acesso | Pre�o |
|-------|--------|-------|
| **Free** | ORM, Migrator, CLI | MIT � gratuito |
| **Pro** | + Feature Flags, Messaging, Extensions | R$ 29/m�s ou R$ 197/ano |
| **Enterprise** | + Telemetria, AI | R$ 69/m�s ou R$ 497/ano |

?? **Licenciamento**: Consulte [LICENSE](./LICENSE) e [LICENSE-SERVER.md](./LICENSE-SERVER.md) para detalhes completos.

## CI/CD

O pipeline automatiza:

- **Build**: documenta��o Docusaurus (pt-BR + en)
- **Preview**: deploy em subdiret�rio para revis�o em pull requests
- **Wiki**: sincroniza��o autom�tica do wiki do reposit�rio
- **Release**: versionamento e sincroniza��o entre subm�dulos

## Desenvolvimento

### Pr�-requisitos

- Node.js >= 20
- Delphi (para os m�dulos do framework)
- Git LFS (para assets grandes)

### Scripts dispon�veis

| Comando | Descri��o |
|---------|-----------|
| `npm start` | Inicia servidor de desenvolvimento Docusaurus |
| `npm run build` | Build de produ��o do site |
| `npm run serve` | Serve o build localmente |
| `./scripts/release/release.ps1` | Script de release automatizada |
| `./scripts/ci/ci-setup.ps1` | Configuração de CI local |
| `./scripts/ci/deploy-wiki.ps1` | Deploy do wiki para GitHub |

## Contribui��o

1. Fa�a um fork do reposit�rio
2. Crie uma branch: `git checkout -b feature/minha-feature`
3. Commit suas mudan�as: `git commit -m "feat: descri��o concisa"`
4. Push: `git push origin feature/minha-feature`
5. Abra um Pull Request

Veja o [guia de contribui��o](https://gabrielferreiramendes.github.io/minusframework/docs/getting-started) para mais detalhes.

---

<p align="center">
  <sub>� 2026 Gabriel Ferreira Mendes. Free modules sob licen�a MIT. M�dulos Pro e Enterprise sob licen�a comercial.</sub>
</p>
