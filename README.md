# MinusFrameWork

**ORM completo, mensageria, telemetria, feature flags e migrador de banco de dados — para Delphi.**

> 🎯 Produtivo, tipado, multi-banco e 100% código Delphi (sem JS, sem JSON, sem XML de mapeamento).

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Delphi](https://img.shields.io/badge/Delphi-11+-red)
![Platform](https://img.shields.io/badge/Platform-Win32%20%7C%20Win64-blue)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/GabrielFerreiraMendes/minusframework-meta)

---

## ✨ O que é o MinusFrameWork?

Um ecossistema de bibliotecas Delphi para construir aplicações corporativas modernas:

| Módulo | Descrição | Grátis |
|--------|-----------|--------|
| **MinusORM** | ORM com mapeamento via atributos RTTI, fluent queries, Unit of Work, Change Tracking, cache, soft delete, audit — **7 bancos de dados** | ✅ MIT |
| **MinusMigrator** | Migração versionada de schema via CLI + GUI + DLL — 7 bancos com diff e auto-migrate | ✅ MIT |
| **MinusFeatureFlags** | Feature flags com engine local, providers e REST API | ✅ MIT |
| **MinusMessaging** | Message bus multi-provider com retry, circuit breaker, sagas e outbox | ✅ MIT |
| **MinusTelemetry** | Tracing e logging estruturado OpenTelemetry-style | ✅ MIT |
| **MinusExtensions** | Wrappers para Horse, JWT e bibliotecas de terceiros | ✅ MIT |

---

## 🚀 Quick Start

### Instalação

[⬇️ Baixe o instalador](https://github.com/GabrielFerreiraMendes/minusframework-meta/releases/latest) (Community Edition)

Ou instale manualmente (só o instalador — o fonte é privado):

```
git clone https://github.com/GabrielFerreiraMendes/minusframework-meta.git
```

> ⚠️ Os submódulos com o código-fonte são **privados**. O clone público traz apenas a documentação e placeholders. Para obter acesso ao código, entre em contato.

Se você é um **mantenedor** com acesso, use:
```
git clone https://github.com/GabrielFerreiraMendes/minusframework-meta.git
cd minusframework-meta
.\setup-dev.ps1 -Token ghp_xxxx
```

### CRUD em 3 minutos

```pascal
// 1. Mapeie sua entidade com atributos
type
  [Tabela('PRODUTO')]
  TProduto = class
  private
    [ChavePrimaria]
    [Coluna('ID')]
    FId: Integer;
    [Coluna('NOME')]
    [NotNull]
    FNome: string;
    [Coluna('PRECO_VENDA')]
    FPrecoVenda: Currency;
  end;

// 2. Configure a conexão
TConfiguracaoORM.RegistrarConexaoComParametros('default',
  TParametrosConexao.Create('FB', 'C:\dados\banco.fdb',
    'SYSDBA', 'masterkey', 'localhost', 3050));

// 3. CRUD
var
  LRepo: TRepositorioBase<TProduto>;
  LProduto: TProduto;
begin
  LRepo := TRepositorioBase<TProduto>.Create(
    TConfiguracaoORM.ConexaoPadrao);

  LProduto := TProduto.Create;
  LProduto.Nome := 'Produto A';
  LProduto.PrecoVenda := 29.90;
  LRepo.Salvar(LProduto);   // INSERT automático

  LProduto := LRepo.BuscarPorId(1);        // SELECT
  LProduto.Nome := 'Produto A (editado)';
  LRepo.Salvar(LProduto);                   // UPDATE

  LRepo.Excluir(1);                         // DELETE
end;
```

### Consultas Fluentes

```pascal
// WHERE com Criteria API type-safe
LLista := TRepositorioORM<TProduto>.Consulta(FConexao)
  .Onde(Criterio('NOME').Igual('Produto A'))
  .Onde(Criterio('PRECO_VENDA').MaiorQue(10))
  .OrdenarPor('NOME')
  .ParaLista;

// OR / AND / NOT / EXISTS / IN subconsulta
LLista := TRepositorioORM<TProduto>.Consulta(FConexao)
  .Onde(OuCriterios([
    Criterio('NOME').Igual('Alpha'),
    Criterio('NOME').Igual('Gamma')
  ]))
  .Onde(Criterio('ID').EmSubconsulta(
    TRepositorioORM<TItem>.Consulta(FConexao, ['PRODUTO_ID']).SQL
  ))
  .ParaLista;
```

---

## 📦 O que vem no instalador

O instalador (Inno Setup) entrega:

- **BPLs e DCPs** — Runtime e Design-Time packages para RAD Studio 11/12
- **Fontes completos** — Código fonte `.pas` para debug e estudo
- **CLIs** — `MinusMigrator_CLI.exe`, `MinusMessaging_CLI.exe`
- **Ferramentas** — `MinusFeatureFlags.exe`, `MinusFeatureFlagsAPI.exe`
- **DLL standalone** — `MinusORM.dll` e `MinusMigrator_DLL.dll` (compatível C)
- **Exemplos** — Projeto `MinusDemo`
- **Documentação** — Guias, changelog e referência de API

---

## 🏗️ Arquitetura

```
                    ┌─────────────────┐
                    │   Sua Aplicação  │
                    └────────┬────────┘
                             │
          ┌──────────────────┼──────────────────┐
          ▼                  ▼                   ▼
  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
  │   MinusORM   │   │ MinusMigrator│   │MinusFeature  │
  │  (RTTI ORM)  │   │  (Schema DB) │   │   Flags      │
  └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
         │                  │                   │
         └──────────────────┼───────────────────┘
                            │
                    ┌───────┴────────┐
                    │  MinusMessaging │
                    │  (Message Bus)  │
                    └───────┬────────┘
                            │
                    ┌───────┴────────┐
                    │ MinusTelemetry │
                    │ (OpenTelemetry)│
                    └───────┬────────┘
                            │
                    ┌───────┴────────┐
                    │   FireDAC +     │
                    │   Horse/JWT    │
                    └────────────────┘
```

---

## 🗄️ Bancos Suportados

| Banco | Provider | Migrator | Testado |
|-------|----------|----------|---------|
| SQLite | ✅ | ✅ | ✅ |
| Firebird | ✅ | ✅ | ✅ |
| PostgreSQL | ✅ | ✅ | ✅ |
| MySQL | ✅ | ✅ | ✅ |
| MariaDB | ✅ | ✅ | ✅ |
| MSSQL | ✅ (Pro) | ✅ | ⏳ |
| Oracle | ✅ (Pro) | ✅ | ⏳ |
| DB2 | ❌ | ✅ | ⏳ |

---

## 📜 Licenciamento

**Dual Licensing:**

| Edição | Licença | Preço | Suporte |
|--------|---------|-------|---------|
| **Community** | [MIT](LICENSE) | **Grátis** | Comunidade |
| **Enterprise** | Comercial | R$ 499/dev/ano | Prioritário |

A Community Edition cobre todas as features essenciais. A Enterprise adiciona providers Oracle/DB2, dashboard de métricas, suporte SLA e licenciamento corporativo.

---

## 📚 Documentação

| Link | Conteúdo |
|------|----------|
| [📖 Docs](Docs/index.md) | Página inicial da documentação |
| [📗 Roadmap](Docs/ROADMAP.md) | Próximos passos e planejamento |
| [📕 Changelog](Docs/CHANGELOG.md) | Histórico de versões |
| [🤝 Contribuindo](Docs/CONTRIBUTING.md) | Como contribuir (em breve) |
| [📊 Crowdfunding](Docs/ESTRATEGIA_CROWDFUNDING.md) | Apoie o projeto |
| [📋 Monorepo vs Submodules](Docs/monorepo_vs_submodules.md) | Decisão arquitetural |

---

## 🧪 Testes

Os módulos possuem suítes de teste com DUnitX. Para executar localmente com Docker:

```powershell
cd ORM
docker compose up -d --wait   # Firebird + PostgreSQL + MySQL + MariaDB
.\run-tests.ps1
```

---

## 🛠️ Requisitos

- **RAD Studio 11 Alexandria** ou superior (Delphi)
- **FireDAC** (nativo)
- **Windows** (Win32/Win64)

---

<p align="center">
  <sub>Desenvolvido com ❤️ pela comunidade Delphi brasileira</sub>
  <br>
  <sub>Copyright © 2026 MinusFrameWork</sub>
</p>
