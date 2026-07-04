---
title: "Mapeamento de Entidades"
---

<span class="badge badge-free">Free</span>

# Mapeamento de Entidades

## Atributos de Mapeamento

| Atributo | Alvo | Descrição |
|----------|------|-----------|
| `[Tabela('NOME')]` | Classe | Nome da tabela no banco |
| `[ChavePrimaria]` | Propriedade | Campo de chave primária |
| `[AutoIncremento]` | Propriedade | Geração automática de ID |
| `[Coluna('NOME')]` | Propriedade | Nome da coluna e tamanho opcional |
| `[Nullable]` | Propriedade | Campo aceita nulo |
| `[Unico]` | Propriedade | Unique constraint |
| `[Indice]` | Propriedade | Índice na coluna |
| `[Default('valor')]` | Propriedade | Valor padrão |
| `[Ignorar]` | Propriedade | Campo não mapeado |
| `[ForeignKey]` | Propriedade | Chave estrangeira |

## Exemplo Completo

```pascal
type
  [Tabela('PRODUTO')]
  TProduto = class(TMFEntity)
  private
    FId: Integer;
    FNome: string;
    FDescricao: string;
    FPreco: Currency;
    FAtivo: Boolean;
    FCategoriaId: Integer;
    FCriadoEm: TDateTime;
  public
    [ChavePrimaria]
    [AutoIncremento]
    [Coluna('ID')]
    property Id: Integer read FId write FId;

    [Coluna('NOME')]
    [Unico]
    property Nome: string read FNome write FNome;

    [Coluna('DESCRICAO')]
    [Nullable]
    property Descricao: string read FDescricao write FDescricao;

    [Coluna('PRECO')]
    [Default('0')]
    property Preco: Currency read FPreco write FPreco;

    [Coluna('ATIVO')]
    property Ativo: Boolean read FAtivo write FAtivo;

    [Coluna('CATEGORIA_ID')]
    [ForeignKey('CATEGORIA', 'ID')]
    property CategoriaId: Integer read FCategoriaId write FCategoriaId;

    [Coluna('CRIADO_EM')]
    property CriadoEm: TDateTime read FCriadoEm write FCriadoEm;
  end;
```

## Tipos Suportados

| Tipo Delphi | Tipo SQL |
|-------------|----------|
| `Integer` | `INTEGER` |
| `Int64` | `BIGINT` |
| `Double` | `DOUBLE PRECISION` |
| `Currency` | `NUMERIC(15,2)` |
| `string` | `VARCHAR(n)` |
| `TDateTime` | `TIMESTAMP` |
| `Boolean` | `BOOLEAN` / `SMALLINT` |
| `TBytes` | `BLOB` |
| `TStream` | `BLOB` |
| `TGuid` | `VARCHAR(38)` |

## Herança

```pascal
type
  TEntidadeBase = class(TMFEntity)
    [ChavePrimaria]
    [AutoIncremento]
    [Coluna('ID')]
    property Id: Integer read FId write FId;

    [Coluna('CRIADO_EM')]
    property CriadoEm: TDateTime read FCriadoEm write FCriadoEm;
  end;

  [Tabela('CLIENTE')]
  TCliente = class(TEntidadeBase)
    [Coluna('NOME')]
    property Nome: string read FNome write FNome;
  end;
```
