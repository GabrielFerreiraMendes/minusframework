# MinusFrameWork License Server

## Local (console)
node server.js

## Windows Service
Para instalar como servico Windows:

1. Clique com botao direito em **install-service.bat** > **Run as Administrator**
2. O servico iniciara automaticamente em http://localhost:3456

Para gerenciar:
- Stop: `.\install-service.bat -Stop` (como admin)
- Start: `.\install-service.bat -Start` (como admin)
- Status: `.\install-service.bat -Status`
- Remover: clique direito em **uninstall-service.bat** > **Run as Administrator**

Logs em: `logs\stdout.log` e `logs\stderr.log`

## API
POST /license/generate
Body: { "tier": "FREE|PRO|ENTERPRISE", "customer": "Nome", "email": "a@b.com", "expires": "2027-12-31" }
