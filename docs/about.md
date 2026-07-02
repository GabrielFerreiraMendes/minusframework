# Sobre o MinusFrameWork

## MissÃ£o

> Fornecer um ecossistema coeso de bibliotecas Delphi que acelerem o desenvolvimento de aplicaÃ§Ãµes corporativas â€” sem sacrificar performance, testabilidade ou boas prÃ¡ticas de engenharia de software.

## HistÃ³ria

O MinusFrameWork nasceu da necessidade de um framework Delphi **moderno, modular e bem testado** que pudesse competir com ecossistemas como Spring Boot (Java), NestJS (Node) e Entity Framework (.NET).

Diferente de frameworks monolÃ­ticos, o MinusFrameWork Ã© dividido em **mÃ³dulos independentes** â€” cada um versionado e publicado separadamente â€” permitindo que equipes adotem apenas o que precisam.

## Arquitetura

O framework segue princÃ­pios de:

- **Clean Architecture** â€” separaÃ§Ã£o clara entre domÃ­nio, infraestrutura e apresentaÃ§Ã£o
- **SOLID** â€” interfaces segregadas, inversÃ£o de dependÃªncia, responsabilidade Ãºnica
- **Object Calisthenics** â€” mÃ©todos curtos, baixa complexidade ciclomÃ¡tica

## RepositÃ³rios

| MÃ³dulo | RepositÃ³rio | DescriÃ§Ã£o |
|--------|-------------|-----------|
| **Meta** (docs, CI/CD) | [minusframework](https://github.com/GabrielFerreiraMendes/minusframework) | OrquestraÃ§Ã£o, instalador e documentaÃ§Ã£o |
| **Core** | [minusframework-core](https://github.com/GabrielFerreiraMendes/minusframework-core) | NÃºcleo compartilhado (conexÃ£o, atributos, tipos) |
| **ORM** | [minusframework-orm](https://github.com/GabrielFerreiraMendes/minusframework-orm) | RepositÃ³rio genÃ©rico, queries, mapeamento |
| **Migrator** | [minusframework-migrator](https://github.com/GabrielFerreiraMendes/minusframework-migrator) | MigraÃ§Ã£o versionada de schema |
| **Messaging** | [minusframework-messaging](https://github.com/GabrielFerreiraMendes/minusframework-messaging) | Message bus, sagas, outbox |
| **Feature Flags** | [minusframework-featureflags](https://github.com/GabrielFerreiraMendes/minusframework-featureflags) | Feature toggles, SSE, REST API |
| **Extensions** | [minusframework-extensions](https://github.com/GabrielFerreiraMendes/minusframework-extensions) | IntegraÃ§Ãµes Horse, JWT |
| **Telemetry** | [minusframework-telemetry](https://github.com/GabrielFerreiraMendes/minusframework-telemetry) | Tracing e logging estruturado |
| **AI** | [minusframework-ai](https://github.com/GabrielFerreiraMendes/minusframework-ai) | MCP Server e agentes inteligentes |
| **CLI** | [minusframework-cli](https://github.com/GabrielFerreiraMendes/minusframework-cli) | CLI de scaffolding |

## Autores

Desenvolvido por **Gabriel Ferreira Mendes** e contribuidores da comunidade.

## LicenÃ§a

O MinusFrameWork Ã© distribuÃ­do em trÃªs tiers:

- **Free** (MIT) â€” ORM SQLite, Migrator, CLI
- **Pro** (Comercial) â€” Multi-banco, Messaging, Feature Flags, Extensions
- **Enterprise** (PerpÃ©tua) â€” Pro + Telemetria, AI, suporte prioritÃ¡rio

Consulte [Licenciamento](licensing.md) e [Planos](pricing.md) para detalhes.
