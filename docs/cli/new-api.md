# `new api`

Cria um projeto REST API completo com servidor Horse + MinusORM.

## Uso

```bash
minus new api <NomeProjeto> [opções]
```

## Opções

| Flag | Descrição | Padrão |
|------|-----------|--------|
| `--dir` | Diretório do projeto | `./<NomeProjeto>` |
| `--port` | Porta do servidor HTTP | `9000` |
| `--db` | Driver de banco (SQLite, PostgreSQL, Firebird) | `SQLite` |
| `--orm` | Incluir dependências do MinusORM | `true` |

## Exemplo

```bash
minus new api MeuApp --db=PostgreSQL --port=8080
```

## Estrutura Gerada

```
meu-app/
  minus.json                    # Configuração
  docker-compose.yml            # Banco de dados para dev
  src/
    MeuApp.dpr                  # Entry point
    Controllers/
      HomeController.pas        # GET /api
      HealthController.pas      # GET /health
    Models/
    Services/
    Entities/
    Config/
      Database.pas              # Configuração de conexão
      Router.pas                # Registro de rotas
```

## `MeuApp.dpr`

```pascal
program MeuApp;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Controllers.Home,
  Controllers.Health,
  Config.Database,
  Config.Router;

begin
  THorse.Use(Jhonson);
  TConexaoConfig.Iniciar;
  TRouterConfig.Registrar;

  THorse.Listen(9000);
end.
```

## `docker-compose.yml`

```yaml
version: '3.8'
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: meu_app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app123
    ports:
      - "5432:5432"
```

## Próximos Passos

```bash
cd meu-app
dcc32 src\MeuApp.dpr
src\MeuApp.exe
# http://localhost:9000/api
```
