# MinusMigrator

Migração versionada de schema de banco de dados — estilo Liquibase/Flyway para Delphi.

Três formas de uso:

- **CLI** — `MinusMigrator.exe` para CI/CD e scripts
- **GUI** — Interface gráfica para gerenciar migrações
- **DLL** — API C para integrar em qualquer linguagem

## Exemplo

```bash
MinusMigrator.exe -c "SQLite:database.db" -d ./migracoes -u
```
