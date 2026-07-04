---
title: "Cache"
---

<span class="badge badge-pro">Pro</span>

# Cache

Sistema de cache em dois níveis: L1 (identity map) e L2 (cache distribuído opcional).

## Cache L1 — Identity Map

Ativo por padrão no repositório. Garante que uma mesma entidade buscada duas vezes retorne a mesma instância em memória:

```pascal
var
  A, B: TPessoa;
begin
  A := Repos.BuscarPorId(1);  // busca no banco
  B := Repos.BuscarPorId(1);  // retorna da memória (mesma instância)
  // A = B (mesmo objeto)
end;
```

## Cache L2 — Distribuído

### Redis

```pascal
Repos.Cache
  .Provider(cpRedis)
  .Host('localhost:6379')
  .Ttl(300)  // 5 minutos
  .Ativar;
```

### Memory (padrão)

```pascal
Repos.Cache
  .Provider(cpMemory)
  .Ttl(60)
  .Ativar;
```

## Invalidar Cache Manualmente

```pascal
Repos.Cache.Limpar;           // limpa cache da entidade
Repos.Cache.LimparTodos;      // limpa cache de todas as entidades
```

## Como Funciona

1. Ao buscar por ID, o repositório consulta o cache primeiro
2. Se não encontrar, busca no banco e armazena
3. Ao salvar ou deletar, invalida as entradas afetadas
4. O cache L2 é opcional e configurável por entidade
