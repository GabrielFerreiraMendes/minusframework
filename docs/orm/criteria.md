---
title: "Criteria API"
---

# Criteria API

Consulta type-safe fluente sem escrever SQL manualmente.

## Estrutura Básica

```pascal
TCriteria.Create
  .Adicionar(TExpression.Propriedade('Nome').Igual('Maria'))
  .Adicionar(TExpression.Propriedade('Ativo').Igual(True));
```

## Operadores

| Método | SQL Gerado |
|--------|------------|
| `.Igual(valor)` | `= ?` |
| `.Diferente(valor)` | `<> ?` |
| `.MaiorQue(valor)` | `> ?` |
| `.MenorQue(valor)` | `< ?` |
| `.MaiorOuIgual(valor)` | `>= ?` |
| `.MenorOuIgual(valor)` | `<= ?` |
| `.Contem(valor)` | `LIKE '%valor%'` |
| `.IniciaCom(valor)` | `LIKE 'valor%'` |
| `.TerminaCom(valor)` | `LIKE '%valor'` |
| `.Entre(v1, v2)` | `BETWEEN ? AND ?` |
| `.Em(valores)` | `IN (?, ?, ...)` |
| `.Nulo` | `IS NULL` |
| `.NaoNulo` | `IS NOT NULL` |

## Combinando Expressões

```pascal
var
  LCriteria: TCriteria;
begin
  LCriteria := TCriteria.Create;
  LCriteria
    .Adicionar(
      TExpression.Propriedade('Status').Igual('ATIVO')
        .E(TExpression.Propriedade('Valor').MaiorQue(100))
    )
    .Adicionar(
      TExpression.Propriedade('Categoria').Igual('PREMIUM')
        .Ou(TExpression.Propriedade('Vip').Igual(True))
    );
end;
```

## Ordenação

```pascal
LCriteria
  .OrderBy('Nome', soAsc)
  .OrderBy('Data', soDesc);
```

## Paginação

```pascal
LCriteria
  .Paginar(1, 20);  // página 1, 20 itens por página
```

## Projeção (campos específicos)

```pascal
LCriteria
  .Selecionar(['Id', 'Nome', 'Email']);
```

## Exemplo Completo

```pascal
var
  LResultado: TArray<TPessoa>;
  LTotal: Integer;
begin
  LResultado := Repos.BuscarPorCriteria(
    TCriteria.Create
      .Adicionar(TExpression.Propriedade('Ativo').Igual(True))
      .Adicionar(TExpression.Propriedade('Nome').Contem('Silva'))
      .OrderBy('Nome', soAsc)
      .OrderBy('Id', soDesc)
      .Paginar(1, 20)
  );

  LTotal := Repos.ContarPorCriteria(
    TCriteria.Create
      .Adicionar(TExpression.Propriedade('Ativo').Igual(True))
  );
end;
```
