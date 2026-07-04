---
title: "CLI — MinusMigrator"
---

<span class="badge badge-free">Free</span>

# CLI — MinusMigrator

A ferramenta de linha de comando para gerenciar migrações de banco de dados.

## Uso

```bash
MinusMigrator.exe <comando> [argumentos]
```

## Comandos

### `create`

Cria um novo arquivo de migração.

```bash
MinusMigrator.exe create "criar_tabela_pedidos"
```

Gera `src/Migrations/20260630_123456_criar_tabela_pedidos.pas`.

### `up`

Aplica migrações pendentes.

```bash
MinusMigrator.exe up --connection=MinhaConexao
```

Opções:

| Flag | Descrição | Padrão |
|------|-----------|--------|
| `--connection` | Nome da conexão FireDAC | obrigatório |
| `--steps` | Número de migrações a aplicar | todas |

### `down`

Reverte a última migração.

```bash
MinusMigrator.exe down --connection=MinhaConexao --steps=1
```

### `status`

Lista migrações aplicadas e pendentes.

```bash
MinusMigrator.exe status --connection=MinhaConexao
```

### `generate`

Gera uma migration a partir de uma tabela existente.

```bash
MinusMigrator.exe generate --connection=MinhaConexao --table=PEDIDO
```

## Exemplo de Migration

```pascal
unit Migration_20260630_CriarTabelaPedidos;

interface

uses
  MF.Migrator;

type
  [Migration('20260630123456')]
  TCriarTabelaPedidos = class(TMigration)
  public
    procedure Up; override;
    procedure Down; override;
  end;

implementation

procedure TCriarTabelaPedidos.Up;
begin
  ExecutarSQL(
    'CREATE TABLE PEDIDO (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  CLIENTE_ID INTEGER NOT NULL,' +
    '  VALOR NUMERIC(15,2) NOT NULL,' +
    '  STATUS VARCHAR(20) DEFAULT ''PENDENTE'',' +
    '  CRIADO_EM TIMESTAMP DEFAULT CURRENT_TIMESTAMP' +
    ')'
  );
end;

procedure TCriarTabelaPedidos.Down;
begin
  ExecutarSQL('DROP TABLE IF EXISTS PEDIDO');
end;

end.
```
