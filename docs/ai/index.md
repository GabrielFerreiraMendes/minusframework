---
title: "Index"
---

﻿# MinusAI

Servidor MCP (Model Context Protocol) que expõe ferramentas de IA para engenharia de software Delphi. Permite que assistentes como Claude, Cursor e GitHub Copilot interajam com seu código e banco de dados.

## O que é MCP?

MCP (Model Context Protocol) é um padrão aberto que permite que modelos de linguagem (LLMs) se conectem a ferramentas externas. O MinusAI implementa um servidor MCP que se comunica via **JSON-RPC 2.0** sobre stdio.

## Funcionalidades

| Ferramenta | Descrição | Exemplo de uso |
|------------|-----------|----------------|
| explicar_codigo | Analisa arquivos .pas e extrai metadados | "O que faz essa unit?" |
| gerar_entidade | Gera entidade ORM via template ou schema | "Cria entidade para tabela CLIENTE" |
| criar_migracao | Gera arquivo de migração versionada | "Cria migração para adicionar coluna email" |
| executar_consulta | Executa SQL contra banco FireDAC real | "Lista todos os pedidos do mês" |
| listar_tabelas | Lista tabelas do banco de dados | "Quais tabelas existem?" |

## Setup

### 1. Ativar a licença Enterprise

```pascal
uses MF.LicenseManager;

begin
  TLicenseManager.Validate('sua-chave-aqui');
end.
```

### 2. Iniciar o servidor MCP

```pascal
uses
  MF.AI.MCP,
  MF.AI.Ferramentas;

var
  LServer: IMCServer;
begin
  LServer := TMCPServer.Criar
    .AdicionarFerramenta(TFerramentaExplicarCodigo.Criar)
    .AdicionarFerramenta(TFerramentaGerarEntidade.Criar)
    .AdicionarFerramenta(TFerramentaCriarMigracao.Criar)
    .AdicionarFerramenta(TFerramentaExecutarConsulta.Criar)
    .AdicionarFerramenta(TFerramentaListarTabelas.Criar);

  // Modo stdio (padrão para integração com IDEs)
  LServer.Iniciar;
end.
```

### 3. Configurar no Claude Desktop

Edite claude_desktop_config.json:

```json
{
  "mcpServers": {
    "minusframework": {
      "command": "MinusAI.exe",
      "args": ["--mcp"],
      "env": {
        "MINUS_LICENSE": "sua-chave-aqui"
      }
    }
  }
}
```

### 4. Configurar no Cursor

1. Abra Cursor Settings > Extensions > MCP
2. Clique em Add new MCP server
3. Preencha:
   - **Name:** minusframework
   - **Type:** stdio
   - **Command:** MinusAI.exe --mcp
   - **Env:** MINUS_LICENSE=sua-chave-aqui

## Exemplos de Uso

### Explicar código

O assistente pergunta:
> "O que faz a unit MF.ORM.Core.pas?"

O servidor responde com:
```json
{
  "arquivo": "MF.ORM.Core.pas",
  "classes": ["TConexaoFactory", "TRepositorioGenerico"],
  "interfaces": ["IConexao", "IRepositorio"],
  "dependencias": ["System.RTTI", "FireDAC.Comp.Client"],
  "linhas": 850
}
```

### Gerar entidade a partir de tabela existente

```json
{
  "ferramenta": "gerar_entidade",
  "parametros": {
    "tabela": "CLIENTE",
    "namespace": "MeuProjeto.Entidades",
    "incluir_atributos": true
  }
}
```

Retorna o código Pascal completo com [Tabela], [ChavePrimaria], [Coluna] para cada coluna.

### Executar consulta

```json
{
  "ferramenta": "executar_consulta",
  "parametros": {
    "sql": "SELECT COUNT(*) as total FROM pedidos WHERE data >= date('now', '-30 days')",
    "conexao": "producao"
  }
}
```

## Arquitetura

```
LLM (Claude/Cursor)
  │  JSON-RPC (stdin/stdout)
  ▼
MinusAI MCP Server
  │
  ├── Ferramenta: explicar_codigo → analisa .pas com RTTI
  ├── Ferramenta: gerar_entidade  → template engine + schema DB
  ├── Ferramenta: criar_migracao  → gera SQL versionado
  ├── Ferramenta: executar_consulta → FireDAC real
  └── Ferramenta: listar_tabelas  → INFORMATION_SCHEMA
```

## Segurança

- O servidor só executa comandos permitidos explicitamente
- Consultas SQL são **read-only** por padrão (UPDATE/INSERT/DELETE bloqueados)
- A chave de licença é lida de variável de ambiente, nunca exposta no código
- Nenhum dado é enviado para servidores externos — tudo roda localmente
