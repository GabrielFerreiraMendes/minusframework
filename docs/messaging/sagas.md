---
title: "Sagas"
---

# Sagas

Sagas são fluxos de trabalho transacionais de longa duração com lógica de compensação para sistemas distribuídos.

## Conceito

Uma saga é uma sequência de passos onde cada passo possui uma **ação** e uma **compensação** (rollback). Se um passo falha, a saga executa as compensações de todos os passos anteriores.

## Exemplo: Pedido + Pagamento + Estoque

```pascal
var
  LSaga: ISaga;
begin
  LSaga := TSagaFactory.Criar('FecharPedido');

  LSaga.Passo
    .Nome('ReservarEstoque')
    .Executar(
      procedure
      begin
        repositorio.Salvar(reserva);
      end)
    .Compensar(
      procedure
      begin
        repositorio.Deletar(reserva);
      end);

  LSaga.Passo
    .Nome('ProcessarPagamento')
    .Executar(
      procedure
      begin
        gateway.Cobrar(pedido.Valor);
      end)
    .Compensar(
      procedure
      begin
        gateway.Estornar(pedido.Valor);
      end);

  LSaga.Passo
    .Nome('AtualizarPedido')
    .Executar(
      procedure
      begin
        pedido.Status := psConfirmado;
        repositorio.Salvar(pedido);
      end)
    .Compensar(
      procedure
      begin
        pedido.Status := psCancelado;
        repositorio.Salvar(pedido);
      end);

  LSaga
    .OnComplete(
      procedure
      begin
        WriteLn('Pedido fechado com sucesso');
      end)
    .OnError(
      procedure(const AErro: Exception)
      begin
        WriteLn('Falha ao fechar pedido: ', AErro.Message);
      end)
    .Iniciar;
end;
```

## Padrão Coreografado vs Orquestrado

| Tipo | Descrição | Quando usar |
|------|-----------|-------------|
| **Coreografado** | Cada serviço publica eventos e reage a eventos de outros serviços | Equipes pequenas, fluxos simples |
| **Orquestrado** | Um coordenador central gerencia o fluxo (como no exemplo acima) | Fluxos complexos, visibilidade total |
