---
title: "Configuração"
---

<span class="badge badge-pro">Pro</span>

# Configuração

## Instalação do Provider

### InMemory (padrão)

```pascal
var
  LBus: IMessageBus;
begin
  LBus := TMessageBusFactory.Criar
    .Provider(pInMemory)
    .Construir;
end;
```

### RabbitMQ

```pascal
LBus := TMessageBusFactory.Criar
  .Provider(pRabbitMQ)
  .Host('localhost')
  .Porta(5672)
  .Usuario('guest')
  .Senha('guest')
  .Vhost('/')
  .Construir;
```

### Kafka

```pascal
LBus := TMessageBusFactory.Criar
  .Provider(pKafka)
  .Host('localhost:9092')
  .GrupoConsumidor('meu-grupo')
  .Construir;
```

### MQTT

```pascal
LBus := TMessageBusFactory.Criar
  .Provider(pMQTT)
  .Host('broker.emqx.io')
  .Porta(1883)
  .ClienteId('meu-app')
  .Construir;
```

### Redis

```pascal
LBus := TMessageBusFactory.Criar
  .Provider(pRedis)
  .Host('localhost:6379')
  .Construir;
```

## Publicar Mensagem

```pascal
LBus.Publicar<TMensagemEmail>(
  TMensagemEmail.Create
    .Destinatario('user@email.com')
    .Assunto('Bem-vindo!')
);
```

## Consumir Mensagem

```pascal
LBus.Consumir<TMensagemEmail>(
  procedure(const AMensagem: TMensagemEmail)
  begin
    EnviarEmail(AMensagem.Destinatario, AMensagem.Assunto);
  end
);
```

## Configurações Avançadas

| Opção | Descrição | Padrão |
|-------|-----------|--------|
| `RetryCount` | Número de tentativas em caso de falha | 3 |
| `RetryDelayMs` | Intervalo entre tentativas | 1000 |
| `CircuitBreakerThreshold` | Falhas consecutivas para abrir o circuito | 5 |
| `OutboxEnabled` | Habilita padrão outbox | false |
