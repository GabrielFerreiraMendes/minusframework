# Licenciamento

O MinusFrameWork é distribuído em três tiers de licença. Cada tier dá acesso a um conjunto específico de módulos e funcionalidades.

## Tiers

### Free

| Módulo | Incluído |
|--------|----------|
| MinusORM (SQLite apenas) | Sim |
| MinusMigrator | Sim |
| MinusCLI | Sim |

**Licença:** MIT. Código-fonte aberto, uso livre para projetos pessoais e aprendizado.

**Restrições:** ORM limitado ao driver SQLite. Demais bancos (Firebird, PostgreSQL, MySQL, MariaDB, MSSQL, Oracle) não estão disponíveis.

---

### Pro

Tudo do **Free**, mais:

| Módulo | Incluído |
|--------|----------|
| MinusORM (todos os 7 bancos) | Sim |
| MinusMigrator | Sim |
| MinusCLI | Sim |
| MinusMessaging | Sim |
| MinusExtensions | Sim |
| MinusFeatureFlags | Sim |

**Uso comercial permitido** mediante aquisição de licença. Inclui atualizações por 12 meses.

---

### Enterprise

Tudo do **Pro**, mais:

| Módulo | Incluído |
|--------|----------|
| MinusTelemetry | Sim |
| MinusAI | Sim |
| Suporte prioritário | Sim |
| Consultoria técnica | Sim |
| Licença perpétua | Sim |

Ideal para empresas que exigem suporte dedicado, implantação on-premise e acesso a todos os módulos do ecossistema.

---

## Dependências de Terceiros

O MinusFrameWork utiliza as seguintes bibliotecas de terceiros, cada uma com sua própria licença:

| Biblioteca | Licença | Módulo |
|-----------|---------|--------|
| FireDAC | Proprietária (Embarcadero) | ORM, Migrator |
| Horse | MIT | Extensions |
| Horse-JWT | MIT | Extensions |
| Horse-Jhonson | MIT | CLI (scaffolding) |
