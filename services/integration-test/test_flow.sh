#!/bin/bash
set -e

echo "=== Integration Test ==="

# 1. Health checks
echo "Checking License Server health..."
curl -sf http://localhost:9080/health | grep -q '"status":"ok"' || { echo "FAIL: License Server health"; exit 1; }

echo "Checking MinusAI Review health..."
curl -sf http://localhost:9081/health | grep -q '"status":"ok"' || { echo "FAIL: MinusAI Review health"; exit 1; }

# 2. GitHub OAuth callback
echo "Testing GitHub OAuth callback..."
curl -sf "http://localhost:9080/auth/github/callback?code=test" | grep -q "token" && echo "  Auth response received"

# 3. Generate license key
echo "Testing license generation..."
TOKEN=$(curl -sf "http://localhost:9080/auth/github/callback?code=test" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
LICENSE_RESPONSE=$(curl -sf -X POST http://localhost:9080/licenses/generate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test-user","license_type":"individual"}')
echo "$LICENSE_RESPONSE" | grep -q '"license_key"' || { echo "FAIL: License generation"; exit 1; }
echo "  License generated: $(echo $LICENSE_RESPONSE | grep -o '"license_key":"[^"]*"' | cut -d'"' -f4)"

# 4. Validate license
echo "Testing license validation..."
LICENSE_KEY=$(curl -sf http://localhost:9080/licenses/mine -H "Authorization: Bearer $TOKEN" | grep -o '"license_key":"[^"]*"' | cut -d'"' -f4)
curl -sf -X POST http://localhost:9080/licenses/validate \
  -H "Content-Type: application/json" \
  -d "{\"license_key\":\"$LICENSE_KEY\",\"device_id\":\"test-device\"}" | grep -q '"valid":true' || { echo "FAIL: License validation"; exit 1; }
echo "  License validated"

# 5. Simulate GitHub webhook
echo "Testing MinusAI webhook..."
WEBHOOK_RESPONSE=$(curl -sf -X POST http://localhost:9081/api/github/webhook \
  -H "Content-Type: application/json" \
  -d '{"action":"opened","number":1,"pull_request":{"title":"Test PR","head":{"sha":"abc123"},"user":{"login":"testuser"}},"repository":{"full_name":"test/repo"}}')
echo "$WEBHOOK_RESPONSE" | grep -q '"review_id"' || { echo "FAIL: Webhook ingestion"; exit 1; }
echo "  Review created: $(echo $WEBHOOK_RESPONSE | grep -o '"review_id":"[^"]*"' | cut -d'"' -f4)"

echo ""
echo "=== All tests passed ==="
