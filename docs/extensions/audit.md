---
title: "Auditoria"
---

<span class="badge badge-pro">Pro</span>

# Auditoria

Rastreia automaticamente quem criou, alterou ou deletou registros e quando.

## Configuração

Adicione o atributo `[Audit]` à entidade:

```pascal
type
  [Tabela('PEDIDO')]
  [Audit]  // ativa auditoria automática
  TPedido = class(TMFEntity)
    [ChavePrimaria]
    [AutoIncremento]
    property Id: Integer read FId write FId;
  end;
```

## Campos Automáticos

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `CRIADO_POR` | string | Usuário que criou o registro |
| `CRIADO_EM` | TDateTime | Data/hora da criação |
| `ALTERADO_POR` | string | Último usuário que alterou |
| `ALTERADO_EM` | TDateTime | Data/hora da última alteração |

## Personalização

```pascal
type
  [Audit('CRIADO_POR', 'CRIADO_EM', 'ALTERADO_POR', 'ALTERADO_EM')]
  TPedido = class(TMFEntity)
    ...
  end;
```

## Como Funciona

O ORM usa o snapshot do Unit of Work para detectar mudanças. Na criação, preenche os campos de criação. Em atualizações, atualiza os campos de alteração. O nome do usuário é obtido automaticamente de `TThread.CurrentUserName` ou pode ser configurado via `TConexaoFactory.UsuarioAuditoria`.
