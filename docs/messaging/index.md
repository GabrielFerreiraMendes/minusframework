---
title: "Index"
---

﻿# MinusMessaging

Message bus multi-provider com suporte a **retry**, **circuit breaker**, **sagas** e **outbox pattern**. Projetado para comunicação assíncrona entre serviços e módulos dentro do ecossistema MinusFrameWork.

## Conceitos

| Conceito | Descrição |
|----------|-----------|
| **Mensagem** | Dados trafegados entre produtor e consumidor. Qualquer record ou class serializável. |
| **Barramento (Bus)** | Abstração do provider. Você publica e consome sem acoplar ao middleware. |
| **Handler** | Função anônima que processa a mensagem. Executada quando uma mensagem chega. |
| **Topologia** | Exchange + fila (RabbitMQ), tópico (Kafka), tópico (MQTT) — configurado automaticamente. |

## Providers

| Provider | Ideal para | Persistência |
|----------|------------|-------------|
| **InMemory** | Testes e desenvolvimento local | Não (memória) |
| **RabbitMQ** | Produção, microsserviços | Sim (disco) |
| **Kafka** | Alta vazão, logs de evento | Sim (log compactado) |
| **MQTT** | IoT, dispositivos embarcados | Opcional (QoS) |
| **Redis** | Filas leves, cache de mensagens | Opcional (RDB/AOF) |

## Fluxo de uma Mensagem

```
Publisher → Bus.Publicar → Provider → Fila/Tópico → Provider → Bus.Consumir → Handler
                                            │
                                     [Retry 3x se falhar]
                                            │
                                     [Circuit Breaker se 5+ falhas consecutivas]
                                            │
                                     [Dead Letter se esgotar tentativas]
```

### Retry com Backoff Exponencial

Quando um handler lança uma exceção, o barramento tenta novamente com intervalo crescente:

| Tentativa | Atraso |
|-----------|--------|
| 1ª | 1s |
| 2ª | 2s |
| 3ª | 4s |
| 4ª+ | 8s (limitado a MaxRetryDelay) |

Após esgotar as tentativas, a mensagem vai para **Dead Letter Queue** (DLQ).

### Circuit Breaker

Se o handler falhar 5 vezes consecutivas, o circuito **abre** por 30 segundos — nenhuma mensagem é entregue durante esse período. Após o timeout, o circuito **meio-abre** e permite uma mensagem de teste. Se bem-sucedida, **fecha** novamente.

### Outbox Pattern

Garante que a mensagem só é publicada se a transação do banco for confirmada:

```
1. BEGIN TRAN
2. Salvar Pedido no banco
3. Inserir linha na tabela Outbox
4. COMMIT
5. Outbox Worker → Bus.Publicar (assíncrono)
6. Deletar linha da Outbox
```

Isso elimina o problema de "mensagem enviada mas transação falhou" ou "transação commitada mas mensagem não enviada".

### Sagas

Uma saga é uma sequência de passos com compensação em caso de falha:

```
ProcessarPedido
  ├── 1. ReservarEstoque ────────── se falhar → EstornarReserva
  ├── 2. CobrarCartao ───────────── se falhar → Reembolsar
  └── 3. ConfirmarEnvio ─────────── se falhar → CancelarEnvio
```

Cada passo publica uma mensagem. O próximo passo é acionado pelo handler do passo anterior. Se qualquer passo falha, os passos já executados são compensados.

## Exemplo Completo — Pedido de Compra

### 1. Definir a mensagem

```pascal
type
  TPedidoCriado = record
    PedidoId: Integer;
    Cliente: string;
    Total: Currency;
  end;
```

### 2. Publicar

```pascal
var
  LBus: IMessageBus;
begin
  LBus := TMessageBusFactory.Criar
    .Provider(pRabbitMQ)
    .Host('localhost')
    .Construir;

  LBus.Publicar<TPedidoCriado>(
    TPedidoCriado.Create(
      42, 'Empresa X', 1500.00
    )
  );
end;
```

### 3. Consumir com retry

```pascal
LBus.Consumir<TPedidoCriado>(
  procedure(const AMsg: TPedidoCriado)
  begin
    // Se lançar exceção, o bus retenta automaticamente
    Faturamento.Faturar(AMsg.PedidoId);
  end
);
```

### 4. Configurar circuit breaker

```pascal
LBus := TMessageBusFactory.Criar
  .Provider(pRabbitMQ)
  .Host('localhost')
  .ConfigurarCircuitBreaker(5, 30000)  // 5 falhas, 30s de abertura
  .Construir;
```

### 5. Habilitar outbox

```pascal
LBus := TMessageBusFactory.Criar
  .Provider(pRabbitMQ)
  .Host('localhost')
  .ConfigurarOutbox(
    TConexaoFactory.Criar
      .Driver('SQLite')
      .Database('outbox.db')
      .Conectar
  )
  .Construir;
```

Agora toda chamada a Publicar dentro de uma transação é enfileirada na outbox e enviada de forma confiável.

## Configurações

| Opção | Descrição | Padrão |
|-------|-----------|--------|
| RetryCount | Número de tentativas | 3 |
| RetryDelayMs | Atraso inicial entre tentativas | 1000 |
| RetryMaxDelayMs | Atraso máximo (backoff) | 8000 |
| CircuitBreakerThreshold | Falhas para abrir circuito | 5 |
| CircuitBreakerTimeoutMs | Tempo de abertura do circuito | 30000 |
| OutboxEnabled | Habilita outbox | false |
| OutboxPollingIntervalMs | Intervalo de verificação da outbox | 1000 |
