# Site Revitalization — MinusFrameWork Docs

Date: 2026-07-04

## Overview

Revitalizar o site de documentação do MinusFrameWork em três frentes paralelas:
GitHub Pages (infra/CI), Documentação (conteúdo/navegação/i18n), UI/UX (visual/performance).

---

## 1. GitHub Pages — Infraestrutura e CI/CD

### Fase 1 (imediata)

- **404.html customizado** — `static/404.html` com branding MinusFrameWork, redirecionamento para home, estilo consistente
- **CNAME** — Arquivo `static/CNAME` para domínio personalizado
- **CI otimizada:**
  - Cache de `node_modules` e diretório `.docusaurus/build` entre runs
  - Deploy preview em PRs: fazer build e disponibilizar como artifact, comentar URL no PR
  - Healthcheck pós-deploy: verificar se o site responde 200 via GitHub API Pages
  - Badge de status do deploy no README

### Fase 2 (futuro)

- Cloudflare na frente (CDN global, SSL gerenciado, analytics)
- Domínio próprio (ex: `minusframework.dev`)

---

## 2. Documentação

### Expandir conteúdo

- Preencher seções esparsas: `docs/ai/`, `docs/telemetry/`, `docs/messaging/`
- Adicionar exemplos reais de código Delphi em cada módulo
- Tutoriais: "Começando do zero", "Migrando de legacy para MinusFrameWork"
- Guia de contribuição

### Reestruturar navegação

- Sidebar: categorias (Getting Started, Core, Pro, Enterprise, Avançado)
- Breadcrumbs automáticos do Docusaurus
- Badges Free/Pro/Enterprise nos títulos das páginas de docs
- FAQ por módulo

### i18n (pt-BR → en)

- Configurar `i18n` do Docusaurus: `defaultLocale: 'pt-BR'`, adicionar `locale: 'en'`
- Traduzir páginas principais: home, about, getting-started, licensing
- Docs completos em inglês como fase posterior

---

## 3. UI/UX

### Refinamento visual

- Animações CSS: fade-in em cards no scroll, hover elevado com `transform: translateY(-2px)`
- Hero: gradiente animado no `background-clip: text`
- Tipografia: carregar Inter + JetBrains Mono com `font-display: swap`
- Dark mode: ajustar contraste, bordas, sombras

### Redesign

- **Homepage:** hero com pattern geométrico sutil (SVG inline), seção "Por que MinusFrameWork?" com 3 valores (Performance, Modularidade, Testabilidade), seção de depoimentos/uso
- **Pricing:** toggle mensal/anual, cards com gradiente no topo, coluna Pro destacada com borda animada
- **Footer:** simplificado — apenas links essenciais + badges de tecnologia + copyright
- **Componentes novos:** `FeatureShowcase` (grid de características), `TestimonialCarousel` (depoimentos)

### Performance

- Meta tags OG/Twitter no `docusaurus.config.ts`
- `sitemap.xml` e `robots.txt` (plugins do Docusaurus)
- Lazy loading de imagens com `loading="lazy"`
- Bundle analysis com `@docusaurus/faster` (já incluso)
- Lighthouse alvo: 90+ em todas as categorias

---

## Execution Strategy

Os 3 pilares serão executados em paralelo via subagentes, cada um com seu próprio implementation plan e PR.

1. **Subagente GitHub Pages** — CI, 404, CNAME, deploy preview
2. **Subagente Documentação** — conteúdo, sidebar, i18n
3. **Subagente UI/UX** — CSS, componentes, homepage redesign

Cada subagente opera independentemente (sem shared state), permitindo paralelismo total.

---

## Success Criteria

- [ ] GitHub Pages deploy automático em cada push na main
- [ ] Deploy preview funcional em PRs
- [ ] Página 404 customizada e domínio configurado
- [ ] Docs de todos os módulos com exemplos reais
- [ ] Sidebar reestruturada com badges de tier
- [ ] i18n pt-BR + en funcional
- [ ] Homepage redesign com hero e seções novas
- [ ] Pricing com toggle e cards melhorados
- [ ] Lighthouse 90+ em performance, acessibilidade, SEO
