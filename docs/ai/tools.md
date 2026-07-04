---
title: "Ferramentas MCP"
---

<span class="badge badge-enterprise">Enterprise</span>

# Ferramentas MCP

## `explicar_codigo`

Explica trechos de código Delphi em linguagem natural.

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `codigo` | string | sim | Código fonte Delphi a ser explicado |
| `conexao` | string | não | Nome da conexão FireDAC (se fornecido, enriquece a análise com schema do banco) |

**Exemplo:**

```json
{
  "codigo": "var r: IRepositorio<TPessoa>; begin r := FConexao.Repositorio<TPessoa>; end;",
  "conexao": "MinhaConexao"
}
```

---

## `gerar_entidade`

Gera uma entidade ORM completa com atributos `[Tabela]`, `[ChavePrimaria]`, `[Coluna]`, etc.

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `descricao` | string | sim | Descrição da entidade (ex: "Produto com id, nome, preco") |

**Exemplo:**

Descrição: `Cliente com id, nome, email, telefone, dataCadastro`

Gera:

```pascal
[Tabela('CLIENTE')]
TCliente = class(TMFEntity)
  [ChavePrimaria]
  [AutoIncremento]
  [Coluna('ID')]
  property Id: Integer read FId write FId;

  [Coluna('NOME')]
  property Nome: string read FNome write FNome;

  [Coluna('EMAIL')]
  property Email: string read FEmail write FEmail;
  ...
```

---

## `criar_migracao`

Gera um script de migration com `CREATE TABLE` a partir de uma conexão FireDAC real.

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `conexao` | string | sim | Nome da conexão FireDAC |
| `tabela` | string | sim | Nome da tabela no banco |

---

## `executar_consulta`

Executa uma consulta SQL arbitrária e retorna os resultados em JSON.

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `sql` | string | sim | Comando SQL a ser executado |

---

## `listar_tabelas`

Lista todas as tabelas disponíveis no banco configurado.

**Parâmetros:** nenhum.
