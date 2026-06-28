# MinusTelemetry

Sistema de tracing e logging estruturado no estilo OpenTelemetry para aplicações Delphi.

## Conceitos

- **Tracer** — ponto de entrada para criar spans
- **Span** — unidade de trabalho com nome, início, fim, atributos e status
- **Exporter** — envia spans para console, arquivo ou serviço externo

## Exemplo

```pascal
var
  LTracer: ITracer;
  LSpan: ISpan;
begin
  LTracer := TTelemetry.CriarTracer('meu-servico');
  LSpan := LTracer.IniciarSpan('processar-pedido');
  try
    LSpan.Atribuir('pedido_id', 42);
    Processar;
    LSpan.DefinirStatus(stOk);
  except
    LSpan.DefinirStatus(stError, Exception(ExceptObject).Message);
    raise;
  end;
end;
```
