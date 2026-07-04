---
title: "Soft Delete"
---

# Soft Delete

Deleção lógica automática: registros não são removidos fisicamente, apenas marcados como inativos.

## Configuração

Na entidade, adicione o atributo `[SoftDelete]` e um campo booleano:

```pascal
type
  [Tabela('PRODUTO')]
  [SoftDelete('ATIVO')]  // campo que indica se o registro está ativo
  TProduto = class(TMFEntity)
    [ChavePrimaria]
    [AutoIncremento]
    property Id: Integer read FId write FId;

    [Coluna('ATIVO')]
    property Ativo: Boolean read FAtivo write FAtivo;
  end;
```

## Comportamento

- `Repositorio.Salvar(entidade)` — respeita o campo `ATIVO`
- `Repositorio.Deletar(entidade)` — faz `UPDATE SET ATIVO = 0` em vez de `DELETE`
- `Repositorio.BuscarTodos` — automaticamente adiciona `WHERE ATIVO = 1`
- `Repositorio.BuscarPorId` — retorna `nil` se o registro estiver marcado como inativo

## Ignorar Soft Delete

Para buscar inclusive registros deletados logicamente:

```pascal
LRepos.IncluirInativos.BuscarTodos;
```

## Como Funciona

O ORM detecta o atributo `[SoftDelete]` na classe e:
1. Intercepta chamadas `Deletar` convertendo em `UPDATE`
2. Adiciona `WHERE campo = 1` automaticamente nas consultas padrão
3. Mantém a consistência mesmo em operações em lote (`DeletarPorCriteria`)
