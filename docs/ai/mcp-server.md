---
title: "MCP Server"
---

# MCP Server

O servidor MCP (Model Context Protocol) expõe ferramentas de IA para consulta e geração de código Delphi, seguindo o padrão JSON-RPC 2.0 sobre stdio.

## Inicialização

```bash
MinusAIServer.exe
```

O servidor lê comandos JSON-RPC da entrada padrão e escreve respostas na saída padrão — integra-se nativamente com IDEs e LLMs que suportam MCP.

## Conexão com Banco de Dados

Opcionalmente, o servidor pode se conectar a um banco de dados real via FireDAC para enriquecer as ferramentas com schema information:

```pascal
var
  LConnector: TMCPSQLConnector;
begin
  LConnector := TMCPSQLConnector.Create;
  LConnector.Driver := 'PostgreSQL';
  LConnector.Host := 'localhost';
  LConnector.Database := 'meudb';
  LConnector.Connect;
end;
```

Variáveis de ambiente: `MCP_DB_DRIVER`, `MCP_DB_HOST`, `MCP_DB_PORT`, `MCP_DB_DATABASE`, `MCP_DB_USER`, `MCP_DB_PASSWORD`.

## Ferramentas

| Ferramenta | Descrição |
|-----------|-----------|
| `explicar_codigo` | Explica um trecho de código Delphi |
| `gerar_entidade` | Gera entidade ORM a partir de uma descrição |
| `criar_migracao` | Gera migration SQL a partir do schema de uma tabela |
| `executar_consulta` | Executa consulta SQL e retorna resultado |
| `listar_tabelas` | Lista tabelas do banco configurado |

Consulte a página [Ferramentas](tools.md) para detalhes de cada uma.
