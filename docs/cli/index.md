# CLI â€” MinusFrameWork Command Line

A ferramenta de linha de comando `minus.exe` oferece scaffolding rÃ¡pido para projetos Delphi com MinusORM e Horse.

## InstalaÃ§Ã£o

Inclusa no instalador do MinusFramework em `C:\MinusFramework\Bin\minus.exe`.

Ou compile manualmente:

```bash
cd Cli\Source
dcc32 MinusCLI.dproj
```

## Uso RÃ¡pido

```bash
minus                          # Lista comandos disponÃ­veis
minus make:entity Pessoa       # Gera entidade
minus new api MinhaAPI         # Cria projeto REST
```

## Comandos

- [`make:entity`](commands.md#makeentity) â€” Gerar entidade ORM
- [`new api`](commands.md#new-api) â€” Criar projeto REST API
