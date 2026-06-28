# CRUD Básico

## Configuração da Conexão

```pascal
var
  LConexao: IConexao;
begin
  LConexao := TConexaoFactory.Criar
    .Driver('SQLite')           // Firebird | PostgreSQL | MySQL | MariaDB | MSSQL | Oracle
    .Database('C:\dados.db')
    .Usuario('SYSDBA')
    .Senha('masterkey')
    .Servidor('localhost')
    .Porta(3050)
    .Conectar;
end;
```

### SQLite em Memória (para testes)

```pascal
LConexao := TConexaoFactory.Criar
  .Driver('SQLite')
  .Database(':memory:')
  .Conectar;
```

## Repositório Genérico

`IRepositorio<T>` é a porta de entrada para operações de banco:

```pascal
var
  LRepos: IRepositorio<TPessoa>;
begin
  LRepos := LConexao.Repositorio<TPessoa>;
  LRepos.GerarTabela; // cria a tabela se não existir
end;
```

## Inserir

```pascal
var
  LPessoa: TPessoa;
begin
  LPessoa := TPessoa.Create;
  LPessoa.Nome := 'Maria';
  LPessoa.Email := 'maria@email.com';
  LRepos.Salvar(LPessoa);

  // Após Salvar, Id é preenchido automaticamente
  WriteLn('ID gerado: ', LPessoa.Id);
end;
```

## Buscar por ID

```pascal
var
  LPessoa: TPessoa;
begin
  LPessoa := LRepos.BuscarPorId(1);
  if Assigned(LPessoa) then
    WriteLn(LPessoa.Nome);
end;
```

## Buscar Todos

```pascal
var
  LTodas: TArray<TPessoa>;
begin
  LTodas := LRepos.BuscarTodos;
  for var LItem in LTodas do
    WriteLn(LItem.Id, ': ', LItem.Nome);
end;
```

## Buscar com Filtro (Criteria)

```pascal
var
  LResultado: TArray<TPessoa>;
begin
  LResultado := LRepos.BuscarPorCriteria(
    TCriteria.Create
      .Adicionar(TExpression.Propriedade('Nome').Contem('Maria'))
      .Adicionar(TExpression.Propriedade('Ativo').Igual(True))
  );
end;
```

## Atualizar

```pascal
var
  LPessoa: TPessoa;
begin
  LPessoa := LRepos.BuscarPorId(1);
  LPessoa.Nome := 'Maria Souza';
  LRepos.Salvar(LPessoa); // detecta mudança e faz UPDATE
end;
```

## Deletar

```pascal
// Deletar uma entidade
LRepos.Deletar(LPessoa);

// Deletar por critério
LRepos.DeletarPorCriteria(
  TCriteria.Create
    .Adicionar(TExpression.Propriedade('Ativo').Igual(False))
);
```

## Trabalhando com Transações

```pascal
var
  LUoW: IUnitOfWork;
begin
  LUoW := LConexao.CriarUnitOfWork;
  try
    LUoW.IniciarTransacao;
    try
      LRepos.Salvar(LPessoa1);
      LRepos.Salvar(LPessoa2);
      LUoW.Commit;
    except
      LUoW.Rollback;
      raise;
    end;
  finally
    LUoW.Free;
  end;
end;
```

!!! tip "Change Tracking"
    O `Salvar()` detecta automaticamente se é INSERT ou UPDATE comparando o estado atual com o snapshot obtido na busca. Não é necessário chamar métodos diferentes para inserir ou atualizar.
