# Licenciamento

O MinusFrameWork é distribuído em três tiers de licença. Cada tier dá acesso a um conjunto específico de módulos e funcionalidades.

## Tiers

### Free

| Módulo | Incluído |
|--------|----------|
| MinusORM (SQLite apenas) | Sim |
| MinusMigrator | Sim |
| MinusCLI | Sim |

**Licença:** MIT. Código-fonte aberto, uso livre para projetos pessoais e aprendizado. Nenhuma renovação necessária.

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

**Uso comercial permitido** mediante aquisição de licença. Licença **perpétua** — o software funciona indefinidamente. Inclui atualizações e suporte por 12 meses. Renovação anual opcional para continuar recebendo novas versões.

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

**Modelo:** Licença perpétua com 12 meses de atualizações e suporte inclusos. Renovação anual opcional.

---

## Como Funciona a Ativação

Cada instalador do MinusFrameWork inclui todos os módulos. O que determina quais funcionalidades ficam disponíveis é a **chave de licença**, validada offline via RSA-2048.

### Formato da Chave

`
{payload}.{assinatura}
`

Onde:
- payload = JSON com 	ier, customer, email, expires (Base64URL)
- ssinatura = RSA-SHA256 sobre o payload (Base64URL)

### Onde Usar

`pascal
uses MF.LicenseManager;

var
  Licenca: TLicenseInfo;
begin
  Licenca := TLicenseManager.Validate('eyJ0aW...');

  if Licenca.IsValid and TLicenseManager.CanAccess(Licenca.Tier, ltPro) then
    HabilitarMensageria;
end;
`

A lib valida offline usando Windows CryptoAPI — **sem chamada de servidor**, sem telemetria, sem envio de dados.

### Gerando Chaves (License Server)

O license server é um repositório privado. Consulte [LICENSE-SERVER.md](https://github.com/GabrielFerreiraMendes/minusframework/blob/main/LICENSE-SERVER.md) para instruções de deploy.

### Segurança

- A chave privada RSA fica **apenas no servidor** (nunca versionada)
- A chave pública é embedada no .exe — qualquer um pode ver, mas só o servidor pode assinar
- Cada chave identifica o comprador; se vazar, você revoga e sabe quem foi

---

## Dependências de Terceiros

O MinusFrameWork utiliza as seguintes bibliotecas de terceiros, cada uma com sua própria licença:

| Biblioteca | Licença | Módulo |
|-----------|---------|--------|
| FireDAC | Proprietária (Embarcadero) | ORM, Migrator |
| Horse | MIT | Extensions |
| Horse-JWT | MIT | Extensions |
| Horse-Jhonson | MIT | CLI (scaffolding) |
