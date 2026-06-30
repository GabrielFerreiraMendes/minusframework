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

## Como Funciona a Ativação

Cada instalador do MinusFrameWork inclui todos os módulos. O que determina quais funcionalidades ficam disponíveis é a **chave de licença**, validada offline via RSA-2048.

### Formato da Chave

```
{payload}.{assinatura}
```

Onde:
- `payload` = JSON com `tier`, `customer`, `email`, `expires` (Base64URL)
- `assinatura` = RSA-SHA256 sobre o payload (Base64URL)

### Onde Usar

```pascal
uses MF.LicenseManager;

var
  Licenca: TLicenseInfo;
begin
  Licenca := TLicenseManager.Validate('eyJ0aW...');

  if Licenca.IsValid and TLicenseManager.CanAccess(Licenca.Tier, ltPro) then
    HabilitarMensageria;
end;
```

A lib valida offline usando Windows CryptoAPI — **sem chamada de servidor**, sem telemetria, sem envio de dados.

### License Server

Para gerar chaves, rode o servidor incluso no meta-repo:

```bash
cd license-server
npm install
npm run generate-keys   # cria private.pem + public.pem
npm start               # HTTP :3456
```

```bash
curl -X POST http://localhost:3456/license/generate \
  -H "Content-Type: application/json" \
  -d '{"tier":"PRO","customer":"Empresa X","email":"x@empresa.com","expires":"2027-12-31"}'
```

### Segurança

- A chave privada RSA fica **apenas no servidor** (nunca versionada)
- A chave pública é embedada no `.exe` — qualquer um pode ver, mas só o servidor pode assinar
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
