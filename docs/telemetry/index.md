---
title: "Index"
---

﻿# MinusTelemetry

Sistema de tracing e logging estruturado no estilo OpenTelemetry para aplicacoes Delphi.
Coleta, processa e exporta spans e logs para analise posterior.

## Conceitos

| Conceito | Descricao |
|----------|-----------|
| **Tracer** | Ponto de entrada. Cria spans nomeados. |
| **Span** | Unidade de trabalho com nome, duracao, atributos e status. |
| **Contexto** | Propaga trace-id e span-id entre chamadas. |
| **Exporter** | Envia spans para console, arquivo, HTTP. |
| **Log** | Evento textual estruturado com timestamp, nivel e atributos. |

## Fluxo

````
Tracer.IniciarSpan('processar-pedido')
  +-- Span filho: consultar-estoque
  +-- Span filho: calcular-frete
  +-- Span filho: salvar-pedido
````

## Exemplo

```pascal
var
  LTracer: ITracer;
  LSpan: ISpan;
begin
  LTracer := TTelemetry.CriarTracer('servico-pedidos');
  LSpan := LTracer.IniciarSpan('processar-pedido');
  try
    LSpan.Atribuir('pedido_id', 42);
    ProcessarPagamento(42);
    LSpan.DefinirStatus(stOk);
  except
    LSpan.DefinirStatus(stError);
    raise;
  finally
    LSpan.Finalizar;
  end;
end;
```

### Exportar para console

```pascal
TTelemetry.Configurar
  .AdicionarExporter(TExporterConsole.Criar)
  .Aplicar;
```

### Exportar para arquivo JSON

```pascal
TTelemetry.Configurar
  .AdicionarExporter(
    TExporterArquivo.Criar
      .Caminho('C:\Logs\tracing.json')
      .RotacionarDiariamente
  )
  .Aplicar;
```

### Exportar via HTTP

```pascal
TTelemetry.Configurar
  .AdicionarExporter(
    TExporterHTTP.Criar
      .Endpoint('http://otel-collector:4318/v1/traces')
      .Timeout(5000)
  )
  .Aplicar;
```

## Logging Estruturado

```pascal
TTelemetry.Logger
  .Info('Pedido criado', ['pedido_id', 42]);

TTelemetry.Logger
  .Error('Falha ao processar pagamento', ['pedido_id', 42]);
```

## Exporters Disponiveis

| Exporter | Formato | Uso |
|----------|---------|-----|
| Console | Texto | Desenvolvimento |
| Arquivo | NDJSON | Producao |
| HTTP | Protobuf/JSON | OTel Collector |

## Boas Praticas

- Finalizar spans no finally
- Nomear spans: verbo + substantivo
- Atributos: tipos simples apenas
- Nao logar dados sensiveis
- Propagar contexto entre threads
