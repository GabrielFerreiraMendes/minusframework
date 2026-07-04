---
title: "Unit of Work"
---

<span class="badge badge-free">Free</span>

# Unit of Work

Gerencia transações, change tracking e identity map para garantir consistência.

## Conceitos

- **Change Tracking** — monitora mudanças nas entidades desde o momento da busca
- **Identity Map** — garante que cada registro do banco seja representado por uma única instância em memória
- **Transação** — agrupa operações em uma unidade atômica

## Uso Básico

```pascal
var
  LUoW: IUnitOfWork;
begin
  LUoW := FConexao.CriarUnitOfWork;
  try
    LUoW.IniciarTransacao;
    try
      Repos.Salvar(Pessoa1);
      Repos.Salvar(Pessoa2);
      Repos.Deletar(Pessoa3);
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

## Detectando Mudanças

```pascal
if LUoW.TemMudancas then
  WriteLn('Há ', LUoW.Mudancas.Count, ' alterações pendentes');

for var LMudanca in LUoW.Mudancas do
begin
  WriteLn(LMudanca.Entidade.ClassName, ' - ', LMudanca.Tipo);
  // LMudanca.Tipo: mtInserido, mtAlterado, mtDeletado
end;
```

## Salvamento Automático

Com `AutoFlush`, as alterações são persistidas automaticamente ao final do escopo:

```pascal
LUoW.AutoFlush := True;
```

## Escopo com `using`

```pascal
LUoW := FConexao.CriarUnitOfWork;
Luow.IniciarTransacao;
LUoW.Salvar<TCliente>(Cliente);
LUoW.Salvar<TPedido>(Pedido);
LUoW.Commit;
```

## Boas Práticas

1. Uma Unit of Work por requisição (Web) ou por operação (Desktop)
2. Mantenha as transações curtas
3. Sempre use `try/except` com `Rollback`
4. Evite `AutoFlush` em operações em lote — prefira controle explícito
