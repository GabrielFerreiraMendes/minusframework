# `make:entity`

Gera uma entidade ORM completa com atributos de mapeamento.

## Uso

```bash
minus make:entity <NomeEntidade> [opções]
```

## Opções

| Flag | Descrição | Padrão |
|------|-----------|--------|
| `--fields` | Lista de campos personalizados | Id, Nome, CriadoEm |
| `--output` | Diretório de saída | `src/Entities` |
| `--table` | Nome da tabela no banco | plural do nome |
| `--connection` | Conexão FireDAC para inferir campos | — |

## Exemplos

### Básico

```bash
minus make:entity Produto
```

### Com campos personalizados

```bash
minus make:entity Produto --fields=Nome:string,Preco:Currency,Estoque:Integer,CategoriaId:Integer
```

### Com conexão (infere campos do banco)

```bash
minus make:entity Produto --connection=MinhaConexao
```

## Saída Gerada

```pascal
unit Entities.Produto;

interface

uses
  System.SysUtils,
  MF.Attributes;

type
  [Tabela('produto')]
  TProduto = class
  private
    FId: Integer;
    FNome: string;
    FPreco: Currency;
    FEstoque: Integer;
    FCategoriaId: Integer;
    FCriadoEm: TDateTime;
  public
    [ChavePrimaria]
    [AutoIncremento]
    [Campo('id')]
    property Id: Integer read FId write FId;

    [Campo('nome')]
    property Nome: string read FNome write FNome;

    [Campo('preco')]
    property Preco: Currency read FPreco write FPreco;

    [Campo('estoque')]
    property Estoque: Integer read FEstoque write FEstoque;

    [Campo('categoria_id')]
    property CategoriaId: Integer read FCategoriaId write FCategoriaId;

    [Campo('criado_em')]
    property CriadoEm: TDateTime read FCriadoEm write FCriadoEm;
  end;

implementation

end.
```

## Templates

Os templates ficam em `~/.minus/templates/entity.pas` e podem ser personalizados. Variáveis disponíveis:

| Variável | Descrição |
|----------|-----------|
| `{{NOME}}` | Nome da entidade |
| `{{TABELA}}` | Nome da tabela |
| `{{CAMPOS}}` | Lista de campos gerados |
| `{{NOME_MINUSCULO}}` | Nome em minúsculas |
