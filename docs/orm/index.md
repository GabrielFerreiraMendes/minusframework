# MinusORM

ORM com RTTI, queries fluentes, Unit of Work e 7 providers de banco.

## Funcionalidades

- **Mapeamento por Atributos** â€” `[Tabela]`, `[ChavePrimaria]`, `[AutoIncremento]`, `[Campo]`, `[Nullable]`
- **RepositÃ³rio GenÃ©rico** â€” `IRepositorio<T>` com CRUD completo
- **Criteria API** â€” consultas type-safe fluentes
- **Unit of Work** â€” change tracking, identity map, transaÃ§Ãµes
- **7 Providers** â€” SQLite, Firebird, PostgreSQL, MySQL, MariaDB, MSSQL, Oracle
- **Cache** â€” cache L1 (identity map) e L2 configurÃ¡vel
- **Soft Delete** â€” deleÃ§Ã£o lÃ³gica automÃ¡tica
- **Auditoria** â€” quem criou, alterou, quando
- **Lazy Loading** â€” carregamento sob demanda de relacionamentos

## Exemplo RÃ¡pido

```pascal
uses MF, MF.Types, MF.Attributes;

type
  [Tabela('PRODUTO')]
  TProduto = class(TMFEntity)
  private
    FId: Integer;
    FNome: string;
    FPreco: Currency;
  public
    [ChavePrimaria]
    [AutoIncremento]
    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property Preco: Currency read FPreco write FPreco;
  end;
```

## SeÃ§Ãµes

- [CRUD BÃ¡sico](crud.md)
- [Mapeamento de Entidades](entities.md)
- [Criteria API](criteria.md)
- [Unit of Work](unit-of-work.md)
- [Providers](providers.md)
