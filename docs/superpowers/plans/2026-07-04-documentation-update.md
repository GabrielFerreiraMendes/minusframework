# Documentação — Conteúdo, Navegação e i18n

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expandir conteúdo dos módulos, reestruturar sidebar com badges Free/Pro/Enterprise, e configurar i18n pt-BR → en.

**Architecture:** Docusaurus i18n nativo com locale `pt-BR` (default) + `en`. Sidebar categorizada. Badges via CSS classes nas páginas MDX.

**Tech Stack:** Docusaurus 3.10.1, MDX, Markdown, TypeScript, PowerShell 5.1

## Global Constraints

- Build do Docusaurus deve passar sem warnings
- pt-BR é locale padrão; en é adicional
- Todos os badges devem usar classes CSS existentes (`.badge-free`, `.badge-pro`, `.badge-enterprise`)

---

### Task 1: Expandir docs dos módulos esparsos (AI, Telemetry, Messaging)

**Files:**
- Modify: `docs/ai/index.md`
- Modify: `docs/telemetry/index.md`
- Modify: `docs/messaging/index.md`

**Interfaces:**
- Consumes: Existing doc folder structure, sidebar config
- Produces: Complete module docs with usage examples

- [ ] **Step 1: Read existing sparse docs**

```powershell
Get-Content "C:\Dev\MinusFrameWork-Meta\docs\ai\index.md"
Get-Content "C:\Dev\MinusFrameWork-Meta\docs\telemetry\index.md"
Get-Content "C:\Dev\MinusFrameWork-Meta\docs\messaging\index.md"
```

- [ ] **Step 2: Check sidebar config for these modules**

```powershell
Get-Content "C:\Dev\MinusFrameWork-Meta\sidebars.ts"
```

- [ ] **Step 3: Rewrite docs/ai/index.md**

```markdown
---
title: MinusAI
description: Agentes inteligentes e servidor MCP para Delphi
sidebar_label: MinusAI
---

<span class="badge badge-enterprise">Enterprise</span>

# MinusAI

MinusAI fornece um servidor **MCP (Model Context Protocol)** e agentes inteligentes para aplicações Delphi.

## Recursos

- **Servidor MCP** — integração com LLMs via protocolo padronizado
- **Agentes** — execução de tarefas com chain-of-thought
- **Ferramentas** — expõe funções do seu sistema como tools para a IA

## Exemplo: Servidor MCP

```pascal
var
  MCPServer: TMinusMCPServer;
begin
  MCPServer := TMinusMCPServer.Create;
  try
    MCPServer.RegisterTool('buscar_cliente', 'Busca cliente por ID', 
      procedure(const Args: TJSONObject; var Result: TJSONValue)
      begin
        Result := TJSONObject.Create;
        Result.AddPair('nome', 'João Silva');
      end);
    MCPServer.Start(8080);
    ReadLn;
  finally
    MCPServer.Free;
  end;
end;
```

## Licenciamento

Disponível apenas no plano **Enterprise**.
```

- [ ] **Step 4: Rewrite docs/telemetry/index.md**

```markdown
---
title: MinusTelemetry
description: Tracing e logging estruturado no padrão OpenTelemetry
sidebar_label: MinusTelemetry
---

<span class="badge badge-enterprise">Enterprise</span>

# MinusTelemetry

MinusTelemetry implementa tracing distribuído e logging estruturado seguindo o padrão **OpenTelemetry**.

## Recursos

- **Tracing** — spans aninhados com context propagation
- **Logging** — logs estruturados em JSON
- **Exporters** — console, arquivo, OTLP (OpenTelemetry Protocol)
- **Integração** — com MinusORM, MinusMessaging e MinusFeatureFlags

## Exemplo: Tracing

```pascal
var
  Tracer: ITracer;
  Span: ISpan;
begin
  Tracer := TTelemetry.CreateTracer('meu-servico');
  Span := Tracer.StartSpan('processar-pedido');
  try
    // ... lógica do negócio
    Span.SetAttribute('pedido_id', 12345);
  finally
    Span.EndSpan;
  end;
end;
```

## Licenciamento

Disponível apenas no plano **Enterprise**.
```

- [ ] **Step 5: Rewrite docs/messaging/index.md**

```markdown
---
title: MinusMessaging
description: Message bus multi-provider com retry, circuit breaker e sagas
sidebar_label: MinusMessaging
---

<span class="badge badge-pro">Pro</span>

# MinusMessaging

MinusMessaging é um barramento de mensagens multi-provider com suporte a retry, circuit breaker, sagas e outbox pattern.

## Recursos

- **Providers:** RabbitMQ, Redis Pub/Sub, Kafka (via extensão)
- **Retry** — retry com backoff exponencial
- **Circuit Breaker** — proteção contra falhas em cascata
- **Sagas** — orquestração de transações distribuídas
- **Outbox Pattern** — garantia de entrega com o banco de dados

## Exemplo: Publicar mensagem

```pascal
var
  Bus: IMessageBus;
begin
  Bus := TMessageBus.Create(TRabbitMQProvider.Create('amqp://localhost'));
  Bus.Publish('pedidos.criados', TJSONObject.Create.AddPair('id', '123'));
end;
```

## Licenciamento

Disponível nos planos **Pro** e **Enterprise**.
```

- [ ] **Step 6: Verify build passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS

---

### Task 2: Reestruturar sidebar com categorias e badges

**Files:**
- Modify: `sidebars.ts`

**Interfaces:**
- Produces: Sidebar with categorized sections and badge indicators in labels

- [ ] **Step 1: Read current sidebar**

```powershell
Get-Content "C:\Dev\MinusFrameWork-Meta\sidebars.ts"
```

- [ ] **Step 2: Rewrite sidebar with categories and badges**

```typescript
import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    {
      type: 'category',
      label: 'Começar',
      items: ['getting-started'],
    },
    {
      type: 'category',
      label: '📦 Free (MIT)',
      items: [
        'orm/index',
        'migrator/index',
        'cli/index',
      ],
    },
    {
      type: 'category',
      label: '⭐ Pro',
      items: [
        'messaging/index',
        'extensions/index',
        'modules/FeatureFlags/index',
      ],
    },
    {
      type: 'category',
      label: '🔒 Enterprise',
      items: [
        'telemetry/index',
        'ai/index',
      ],
    },
    {
      type: 'category',
      label: 'Sobre',
      items: ['about', 'licensing'],
    },
  ],
};

export default sidebars;
```

- [ ] **Step 3: Verify build passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS, zero warnings

---

### Task 3: Adicionar badges Free/Pro/Enterprise nas páginas de docs

**Files:**
- Identify all doc pages that need badges

Esta task adiciona `<span class="badge badge-{tier}">{Tier}</span>` no topo de cada página de documentação, conforme o tier do módulo.

- [ ] **Step 1: Scan all doc files for tier annotation**

```powershell
Get-ChildItem -Path "C:\Dev\MinusFrameWork-Meta\docs" -Filter "*.md" -Recurse | Select-Object FullName
```

- [ ] **Step 2: Add badges to each page**

For each doc page, add at the top (after frontmatter):

Free modules (orm, migrator, cli):
```markdown
<span class="badge badge-free">Free</span>
```

Pro modules (messaging, extensions, featureflags):
```markdown
<span class="badge badge-pro">Pro</span>
```

Enterprise modules (telemetry, ai):
```markdown
<span class="badge badge-enterprise">Enterprise</span>
```

- [ ] **Step 3: Verify build passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS

---

### Task 4: Adicionar breadcrumbs automáticos

**Files:**
- Modify: `docusaurus.config.ts`

- [ ] **Step 1: Enable breadcrumbs in theme config**

Add to `presets.docs` config:

```typescript
docs: {
  sidebarPath: './sidebars.ts',
  editUrl: 'https://github.com/minusframework/minusframework/edit/main/docs/',
  breadcrumbs: true,
  showLastUpdateTime: true,
  showLastUpdateAuthor: true,
},
```

- [ ] **Step 2: Verify build passes**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS

---

### Task 5: Configurar i18n pt-BR + en

**Files:**
- Modify: `docusaurus.config.ts`
- Create: `i18n/en/docusaurus-theme-classic/navbar.json`
- Create: `i18n/en/docusaurus-theme-classic/footer.json`
- Create: `i18n/en/code.json`

**Interfaces:**
- Produces: i18n configuration with English translations for UI strings

- [ ] **Step 1: Update docusaurus.config.ts i18n config**

```typescript
i18n: {
  defaultLocale: 'pt-BR',
  locales: ['pt-BR', 'en'],
  localeConfigs: {
    'pt-BR': { label: 'Português (Brasil)', direction: 'ltr' },
    en: { label: 'English', direction: 'ltr' },
  },
},
```

- [ ] **Step 2: Create English navbar translations**

Create `i18n/en/docusaurus-theme-classic/navbar.json`:

```json
{
  "title": {
    "message": "MinusFrameWork",
    "description": "The title in the navbar"
  },
  "item.label.Documentação": {
    "message": "Documentation",
    "description": "Navbar item with label Documentação"
  },
  "item.label.Planos": {
    "message": "Pricing",
    "description": "Navbar item with label Planos"
  },
  "item.label.Sobre": {
    "message": "About",
    "description": "Navbar item with label Sobre"
  },
  "item.label.Licenciamento": {
    "message": "Licensing",
    "description": "Navbar item with label Licenciamento"
  },
  "item.label.GitHub": {
    "message": "GitHub",
    "description": "Navbar item with label GitHub"
  }
}
```

- [ ] **Step 3: Create English footer translations**

Create `i18n/en/docusaurus-theme-classic/footer.json`:

```json
{
  "link.title.Docs": {
    "message": "Docs",
    "description": "The title of the footer links column"
  },
  "link.title.Planos": {
    "message": "Plans",
    "description": "The title of the footer links column"
  },
  "link.title.Suporte": {
    "message": "Support",
    "description": "The title of the footer links column"
  },
  "link.item.label.Guia Rápido": {
    "message": "Quick Start",
    "description": "The label of footer link with label=Guia Rápido linking to /docs/getting-started"
  },
  "link.item.label.ORM": {
    "message": "ORM",
    "description": "The label of footer link with label=ORM linking to /docs/orm/"
  },
  "link.item.label.CLI": {
    "message": "CLI",
    "description": "The label of footer link with label=CLI linking to /docs/cli/"
  },
  "link.item.label.Free": {
    "message": "Free",
    "description": "The label of footer link with label=Free linking to /pricing"
  },
  "link.item.label.Pro": {
    "message": "Pro",
    "description": "The label of footer link with label=Pro linking to /pricing"
  },
  "link.item.label.Enterprise": {
    "message": "Enterprise",
    "description": "The label of footer link with label=Enterprise linking to /pricing"
  },
  "link.item.label.GitHub Issues": {
    "message": "GitHub Issues",
    "description": "The label of footer link with label=GitHub Issues linking to https://github.com/minusframework/minusframework/issues"
  },
  "link.item.label.E-mail": {
    "message": "Email",
    "description": "The label of footer link with label=E-mail linking to mailto:gabrielferreiramendes.dev@gmail.com"
  }
}
```

- [ ] **Step 4: Create English document translations for key pages**

Translate `src/pages/index.tsx` → `i18n/en/docusaurus-plugin-content-pages/index.tsx`
Translate `src/pages/about.md` → `i18n/en/docusaurus-plugin-content-pages/about.md`
Translate `docs/getting-started.md` → `i18n/en/docusaurus-plugin-content-docs/current/getting-started.md`

- [ ] **Step 5: Verify build with both locales**

```powershell
cd C:\Dev\MinusFrameWork-Meta
npx docusaurus build 2>&1
```
Expected: SUCCESS, zero warnings
