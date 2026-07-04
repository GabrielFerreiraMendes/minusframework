# UI/UX — Refinamento Visual, Redesign e Performance

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modernizar visual do site com animações, redesign da homepage e pricing, e otimizações de performance/SEO.

**Architecture:** Custom CSS + React componentes Docusaurus. Animações via CSS transitions/animation. Performance via metatags e lazy loading.

**Tech Stack:** Docusaurus 3.10.1, CSS3, React 19, TypeScript

## Global Constraints

- Build do Docusaurus deve passar sem warnings
- Dark mode deve ser mantido e melhorado
- Lighthouse alvo: 90+ em todas as categorias
- Nenhuma dependência externa nova (sem libs de animação)

---

### Task 1: Refinamento CSS — animações, tipografia, dark mode

**Files:**
- Modify: `src/css/custom.css`

- [ ] **Step 1: Read current custom.css**

```powershell
Get-Content "C:\Dev\MinusFrameWork-Meta\src\css\custom.css"
```

- [ ] **Step 2: Add animações e refinamentos**

Append ao final do `custom.css`:

```css
/* ===== Animações ===== */
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(16px); }
  to   { opacity: 1; transform: translateY(0); }
}

.card, .module-card {
  animation: fadeInUp 0.4s ease both;
}
.card:nth-child(2), .module-card:nth-child(2) { animation-delay: 0.1s; }
.card:nth-child(3), .module-card:nth-child(3) { animation-delay: 0.2s; }
.card:nth-child(4), .module-card:nth-child(4) { animation-delay: 0.3s; }
.card:nth-child(5), .module-card:nth-child(5) { animation-delay: 0.4s; }
.card:nth-child(6), .module-card:nth-child(6) { animation-delay: 0.5s; }

.card:hover, .module-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0,0,0,0.1);
  border-color: var(--ifm-color-primary);
}

/* ===== Hero gradient ===== */
.hero__title span.gradient-text {
  background: linear-gradient(135deg, var(--ifm-color-primary) 0%, var(--ifm-color-secondary) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* ===== Tipografia refinada ===== */
:root {
  --ifm-line-height-base: 1.6;
}
h1, h2, h3, h4 {
  letter-spacing: -0.02em;
}

/* ===== Dark mode refinements ===== */
[data-theme='dark'] .card:hover,
[data-theme='dark'] .module-card:hover {
  box-shadow: 0 4px 20px rgba(0,0,0,0.3);
}

[data-theme='dark'] .navbar {
  border-bottom: 1px solid var(--ifm-toc-border-color);
}

/* ===== Pricing card improvements ===== */
.pricing-card {
  transition: transform 0.2s, box-shadow 0.2s;
}
.pricing-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 30px rgba(0,0,0,0.12);
}
.pricing-card.highlighted {
  border-color: var(--ifm-color-primary);
  border-width: 2px;
}
.pricing-card .pricing-badge {
  position: absolute;
  top: -0.75rem;
  left: 50%;
  transform: translateX(-50%);
  background: var(--ifm-color-primary);
  color: white;
  padding: 0.2rem 1rem;
  border-radius: 2rem;
  font-size: 0.75rem;
  font-weight: 700;
}

/* ===== Responsive improvements ===== */
@media (max-width: 768px) {
  .hero__title { font-size: 2rem; }
  .module-grid { grid-template-columns: 1fr; }
  .footer__links { flex-direction: column; gap: 1.5rem; }
}
```

- [ ] **Step 3: Verify build passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS, zero warnings

---

### Task 2: Redesign da Homepage

**Files:**
- Modify: `src/pages/index.tsx`

- [ ] **Step 1: Read current homepage**

```powershell
Get-Content "C:\Dev\MinusFrameWork-Meta\src\pages\index.tsx"
```

- [ ] **Step 2: Rewrite homepage with hero gradient + "Por que" section**

```tsx
import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import HighlightCards from '../components/HighlightCards';
import ModuleGrid from '../components/ModuleGrid';

const WHY_MINUS = [
  {
    icon: '\u26A1',
    title: 'Performance',
    desc: 'Componentes Delphi otimizados para aplicações corporativas de alta demanda, com baixo overhead e profiling integrado.',
  },
  {
    icon: '\u{1F9EA}',
    title: 'Modularidade',
    desc: 'Use só o que precisa. Free (MIT) até Enterprise. Cada módulo é independente e testável isoladamente.',
  },
  {
    icon: '\u{1F4CB}',
    title: 'Testabilidade',
    desc: 'Clean Architecture + SOLID + Object Calisthenics. Injeção de dependência, mocks e testes desde o primeiro dia.',
  },
];

export default function Home(): React.ReactElement {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout title="MinusFrameWork" description={siteConfig.tagline}>
      <main>
        <section className="hero">
          <h1 className="hero__title">
            Framework Delphi<br />
            <span className="gradient-text">moderno e modular</span>
          </h1>
          <p className="hero__subtitle">{siteConfig.tagline}</p>
          <div className="hero__cta">
            <Link className="button button--lg button--primary" to="/docs/getting-started">
              Começar agora →
            </Link>
            <Link className="button button--lg button--secondary" to="/pricing">
              Ver planos
            </Link>
          </div>
        </section>

        <section className="container" style={{padding: '3rem 1rem'}}>
          <h2 style={{textAlign: 'center', marginBottom: '2rem'}}>Por que MinusFrameWork?</h2>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
            gap: '1.5rem',
            marginBottom: '3rem',
          }}>
            {WHY_MINUS.map((item) => (
              <div key={item.title} className="card" style={{textAlign: 'center', padding: '2rem 1.5rem'}}>
                <div style={{fontSize: '2.5rem', marginBottom: '0.75rem'}}>{item.icon}</div>
                <h3 style={{marginBottom: '0.5rem'}}>{item.title}</h3>
                <p style={{fontSize: '0.9rem', color: 'var(--ifm-color-emphasis-600)', lineHeight: 1.6}}>
                  {item.desc}
                </p>
              </div>
            ))}
          </div>
        </section>

        <section className="container" style={{padding: '0 1rem 2rem'}}>
          <h2 style={{textAlign: 'center', marginBottom: '0.5rem'}}>Módulos gratuitos</h2>
          <p style={{textAlign: 'center', color: 'var(--ifm-color-emphasis-600)', marginBottom: '1.5rem'}}>
            Comece com esses módulos sem custo — licença MIT.
          </p>
          <HighlightCards />

          <h2 style={{textAlign: 'center', marginTop: '3rem', marginBottom: '0.5rem'}}>Ecossistema completo</h2>
          <p style={{textAlign: 'center', color: 'var(--ifm-color-emphasis-600)', marginBottom: '1.5rem'}}>
            Todos os módulos do MinusFrameWork, do Free ao Enterprise.
          </p>
          <ModuleGrid />
        </section>
      </main>
    </Layout>
  );
}
```

- [ ] **Step 3: Verify build passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS

---

### Task 3: Redesign da página de Pricing

**Files:**
- Modify: `src/pages/pricing.tsx`

**Interfaces:**
- Consumes: `Badge` component, classes: `.pricing-card`, `.pricing-badge`, `.pricing-card.highlighted`

- [ ] **Step 1: Read current pricing**

```powershell
Get-Content "C:\Dev\MinusFrameWork-Meta\src\pages\pricing.tsx"
```

- [ ] **Step 2: Rewrite pricing with CSS classes and improved layout**

```tsx
import React, { useState } from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import Badge from '../components/Badge';

interface PricingPlan {
  name: string;
  price: { monthly: number; yearly: number };
  license: string;
  devs: string;
  badge: 'free' | 'pro' | 'enterprise';
  highlighted?: boolean;
  features: { name: string; included: boolean }[];
}

const PLANS: PricingPlan[] = [
  {
    name: 'Free', price: { monthly: 0, yearly: 0 }, license: 'MIT', devs: '1 desenvolvedor',
    badge: 'free',
    features: [
      { name: 'MinusORM (SQLite)', included: true },
      { name: 'MinusORM (7 bancos)', included: false },
      { name: 'MinusMigrator', included: true },
      { name: 'MinusCLI', included: true },
      { name: 'MinusMessaging', included: false },
      { name: 'MinusExtensions', included: false },
      { name: 'MinusFeatureFlags', included: false },
      { name: 'MinusTelemetry', included: false },
      { name: 'MinusAI', included: false },
    ],
  },
  {
    name: 'Pro', price: { monthly: 29, yearly: 197 }, license: 'Perpétua', devs: '1 desenvolvedor',
    badge: 'pro', highlighted: true,
    features: [
      { name: 'MinusORM (SQLite)', included: true },
      { name: 'MinusORM (7 bancos)', included: true },
      { name: 'MinusMigrator', included: true },
      { name: 'MinusCLI', included: true },
      { name: 'MinusMessaging', included: true },
      { name: 'MinusExtensions', included: true },
      { name: 'MinusFeatureFlags', included: true },
      { name: 'MinusTelemetry', included: false },
      { name: 'MinusAI', included: false },
    ],
  },
  {
    name: 'Enterprise', price: { monthly: 69, yearly: 497 }, license: 'Perpétua', devs: 'até 5 por bloco',
    badge: 'enterprise',
    features: [
      { name: 'MinusORM (SQLite)', included: true },
      { name: 'MinusORM (7 bancos)', included: true },
      { name: 'MinusMigrator', included: true },
      { name: 'MinusCLI', included: true },
      { name: 'MinusMessaging', included: true },
      { name: 'MinusExtensions', included: true },
      { name: 'MinusFeatureFlags', included: true },
      { name: 'MinusTelemetry', included: true },
      { name: 'MinusAI', included: true },
    ],
  },
];

function formatPrice(price: number): string {
  if (price === 0) return 'Grátis';
  return `R$ ${price}`;
}

export default function Pricing(): React.ReactElement {
  const [yearly, setYearly] = useState(true);
  return (
    <Layout title="Planos" description="Compare os planos Free, Pro e Enterprise do MinusFrameWork.">
      <main className="container" style={{ padding: '2rem 1rem', maxWidth: '1000px', margin: '0 auto' }}>
        <h1 style={{ textAlign: 'center', marginBottom: '0.5rem' }}>Planos</h1>
        <p style={{ textAlign: 'center', color: 'var(--ifm-color-emphasis-600)', marginBottom: '1.5rem' }}>
          Escolha o plano ideal para sua equipe
        </p>

        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '0.75rem', marginBottom: '2rem' }}>
          <span style={{ fontSize: '0.9rem', color: !yearly ? 'var(--ifm-color-primary)' : 'var(--ifm-color-emphasis-600)', fontWeight: yearly ? 400 : 700 }}>Mensal</span>
          <label style={{ position: 'relative', display: 'inline-block', width: '48px', height: '26px' }}>
            <input type="checkbox" checked={yearly} onChange={() => setYearly(!yearly)}
              style={{ opacity: 0, width: 0, height: 0 }} />
            <span style={{
              position: 'absolute', cursor: 'pointer', inset: 0,
              background: yearly ? 'var(--ifm-color-primary)' : '#ccc',
              borderRadius: '26px', transition: 'background 0.2s',
            }}>
              <span style={{
                position: 'absolute', content: '', height: '20px', width: '20px',
                left: yearly ? '26px' : '2px', bottom: '3px',
                background: 'white', borderRadius: '50%', transition: 'left 0.2s',
              }} />
            </span>
          </label>
          <span style={{ fontSize: '0.9rem', color: yearly ? 'var(--ifm-color-primary)' : 'var(--ifm-color-emphasis-600)', fontWeight: yearly ? 700 : 400 }}>
            Anual <span style={{ fontSize: '0.75rem', color: 'var(--ifm-color-primary)', fontWeight: 600 }}>(2 meses grátis)</span>
          </span>
        </div>

        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '1rem', margin: '2rem 0',
        }}>
          {PLANS.map((p) => {
            const price = yearly ? p.price.yearly : p.price.monthly;
            const period = yearly ? (price > 0 ? '/ano' : '') : (price > 0 ? '/mês' : '');
            return (
              <div key={p.name} className={`pricing-card${p.highlighted ? ' highlighted' : ''}`} style={{
                border: `1px solid ${p.highlighted ? 'var(--ifm-color-primary)' : 'var(--ifm-toc-border-color)'}`,
                borderRadius: 'var(--ifm-card-border-radius)',
                padding: '1.5rem',
                background: p.highlighted ? 'rgba(224,122,95,0.04)' : 'var(--ifm-card-background-color, white)',
                position: 'relative',
              }}>
                {p.highlighted && <div className="pricing-badge">Mais popular</div>}
                <div style={{ textAlign: 'center', marginBottom: '1rem' }}>
                  <h3 style={{ margin: 0 }}>{p.name}</h3>
                  <div style={{ fontSize: '2rem', fontWeight: 800, margin: '0.5rem 0' }}>
                    {formatPrice(price)}<span style={{ fontSize: '0.9rem', fontWeight: 400, color: 'var(--ifm-color-emphasis-600)' }}>{period}</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
                    <Badge tier={p.badge} />
                  </div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--ifm-color-emphasis-600)' }}>{p.license} &middot; {p.devs}</div>
                </div>
                <div style={{ borderTop: '1px solid var(--ifm-toc-border-color)', paddingTop: '0.75rem' }}>
                  {p.features.map((f) => (
                    <div key={f.name} style={{
                      display: 'flex', justifyContent: 'space-between', padding: '0.35rem 0',
                      fontSize: '0.85rem', opacity: f.included ? 1 : 0.4,
                    }}>
                      <span>{f.name}</span>
                      <span style={{ color: f.included ? 'var(--ifm-color-primary)' : undefined }}>
                        {f.included ? '✓' : '—'}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        <section style={{ marginTop: '3rem' }}>
          <h2>Dúvidas Frequentes</h2>
          <details><summary><strong>Preciso pagar todo ano?</strong></summary>
            Não. As licenças Pro e Enterprise são <strong>perpétuas</strong> — o software continua funcionando mesmo sem renovar.
          </details>
          <details><summary><strong>Posso usar em mais de uma máquina?</strong></summary>
            Sim, desde que o mesmo desenvolvedor. Cada licença é por desenvolvedor, não por máquina.
          </details>
          <details><summary><strong>Posso atualizar do Free para o Pro?</strong></summary>
            Sim. Basta adquirir a chave Pro e aplicar no mesmo instalador.
          </details>
        </section>
      </main>
    </Layout>
  );
}
```

- [ ] **Step 3: Verify build passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS

---

### Task 4: SEO e Performance — meta tags, sitemap, robots

**Files:**
- Modify: `docusaurus.config.ts`
- Create: `static/robots.txt`

- [ ] **Step 1: Add OG/Twitter meta tags + sitemap plugin**

In `docusaurus.config.ts`, update `themeConfig`:

```typescript
themeConfig: {
  image: 'img/logo.svg',
  metadata: [
    { name: 'keywords', content: 'delphi, framework, orm, delphi framework, minusframework, delphi orm' },
    { property: 'og:title', content: 'MinusFrameWork — Framework Delphi moderno e modular' },
    { property: 'og:description', content: siteConfig.tagline },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
    { name: 'twitter:title', content: 'MinusFrameWork' },
    { name: 'twitter:description', content: siteConfig.tagline },
  ],
  // ... rest of existing themeConfig
},
```

Enable sitemap plugin by adding to the preset:

```typescript
presets: [
  [
    'classic',
    {
      docs: { ... },
      blog: false,
      sitemap: {
        lastmod: 'date',
        changefreq: 'weekly',
        priority: 0.5,
        ignorePatterns: ['/tags/**'],
        filename: 'sitemap.xml',
      },
      theme: { ... },
    },
  ],
],
```

- [ ] **Step 2: Create robots.txt**

```text
User-agent: *
Allow: /
Sitemap: https://gabrielferreiramendes.github.io/minusframework/sitemap.xml
```

- [ ] **Step 3: Verify build passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS

---

### Task 5: Lighthouse — lazy loading e audit

**Files:**
- Verify all images use `loading="lazy"`

- [ ] **Step 1: Check existing images for lazy loading**

```powershell
Select-String -Path "C:\Dev\MinusFrameWork-Meta\src\**\*.tsx" -Pattern "img.*src="
```

- [ ] **Step 2: Run Lighthouse CI**

```powershell
# Install Lighthouse CI
npm install -g @lhci/cli

# Run audit on build output
npx lhci autorun --collect.staticDistDir=build --collect.url=http://localhost:3000/ 2>&1
```
Expected: All categories 90+

If not available locally, add a Lighthouse CI step to the GitHub Actions workflow:

```yaml
- name: Lighthouse CI
  if: github.event_name == 'pull_request'
  run: |
    npx lhci autorun --collect.staticDistDir=build --collect.url=https://gabrielferreiramendes.github.io/minusframework/ --upload.target=temporary-public-storage 2>&1
```
