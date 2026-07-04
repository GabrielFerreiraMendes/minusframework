---
title: MinusExtensions
sidebar_label: MinusExtensions
---

<span class="badge badge-pro">Pro</span>

﻿# MinusExtensions

Pacote de extensoes plugaveis que adicionam funcionalidades transversais ao MinusORM.

## Extensoes Disponiveis

| Extensao | Descricao |
|----------|-----------|
| **Soft Delete** | Delecao logica com `[DesabilitarSoftDelete]` |
| **Auditoria** | Quem criou, alterou e quando |
| **Cache L2** | Cache distribuiido (Redis/Memcached) |
| **Bulk** | Insercao/atualizacao em lote |
| **Multi-Tenancy** | Isolamento por tenant |
| **JSON Serializer** | Entidades para JSON |
| **Async** | Operacoes assincronas |

---

## Soft Delete

Marca registros como inativos em vez de remove-los:

```pascal
type
  [Tabela('PRODUTO')]
  TProduto = class(TMFEntity)
  private
    FAtivo: Boolean;
  public
    [DesabilitarSoftDelete]
    property Ativo: Boolean read FAtivo write FAtivo;
  end;
```

```pascal
// DELETE vira UPDATE Ativo = false
LRepos.Deletar(Produto);

// WHERE ativo = 1 adicionado automaticamente
LTodos := LRepos.BuscarTodos;

// Incluir inativos
LTodos := LRepos.BuscarTodosComInativos;
```

---

## Auditoria

```pascal
type
  [Tabela('CLIENTE')]
  [AuditLog]
  TCliente = class(TMFEntity) ...
```

Salvar() preenche automaticamente:
- criado_por, criado_em
- alterado_por, alterado_em

---

## Cache L2

```pascal
LConexao.Configuracao
  .CacheL2(
    TCacheRedis.Criar
      .Host('localhost:6379')
      .TTLPadrao(300)
  );

// Cache hit: 300ms -> 1ms
LPessoa := LRepos.BuscarPorId(1);
```

---

## Bulk Operations

```pascal
LRepos.BulkInsert(MinhaLista);
LRepos.BulkUpdate(Criteria, Updates);
LRepos.BulkDelete(Criteria);
```

---

## Multi-Tenancy

```pascal
  [Tabela('PEDIDO')]
  [Tenant('EMPRESA_ID')]
  TPedido = class(TMFEntity) ...
```

WHERE empresa_id = X adicionado automaticamente em todas as queries.

---

## JSON Serializer

```pascal
var LJson: string;
begin
  LJson := TJSONSerializer.EntityToJson(Pessoa);
  LJson := TJSONSerializer.ListToJson(Lista);
end;
```

---

## Async

```pascal
var LTask: ITask<TArray<TPessoa>>;
begin
  LTask := LRepos.BuscarTodosAsync(Procedure(AResult)
  begin
    ExibirResultado(AResult);
  end);
end;
```
