const crypto = require('crypto');
const fs = require('fs');

const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', {
  modulusLength: 2048,
  publicKeyEncoding: { type: 'spki', format: 'pem' },
  privateKeyEncoding: { type: 'pkcs1', format: 'pem' }
});

fs.writeFileSync('private.pem', privateKey);
fs.writeFileSync('public.pem', publicKey);

// Extract raw DER bytes for Delphi embed (base64 DER)
const publicDer = publicKey
  .replace('-----BEGIN PUBLIC KEY-----', '')
  .replace('-----END PUBLIC KEY-----', '')
  .replace(/\s/g, '');

console.log('=== Keys generated ===');
console.log('');
console.log('private.pem  — guarde em local seguro (NUNCA versionar)');
console.log('public.pem   — embed no Delphi como constante');
console.log('');
console.log('Coloque no MF.LicenseManager.pas:');
console.log('');
console.log(`const`);
console.log(`  PUBLIC_KEY_B64 = '${publicDer}';`);
