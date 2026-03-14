const fs = require('fs');
const { execSync } = require('child_process');

function run(cmd) {
  try {
    console.log(`> ${cmd}`);
    return execSync(cmd, { stdio: 'inherit' });
  } catch (e) {
    console.error(`Falha ao executar: ${cmd}`);
    return null;
  }
}

console.log('\n=== Iniciando auto-reparo do Workspace ===');
console.log('Tentando restaurar apps/ diretamente da branch remota (origin/work)...\n');

run('git fetch origin work');
run('git checkout origin/work -- apps/backend apps/frontend');

const missing = [];
if (!fs.existsSync('apps/backend/package.json')) missing.push('apps/backend');
if (!fs.existsSync('apps/frontend/package.json')) missing.push('apps/frontend');

if (missing.length === 0) {
  console.log('\n[OK] Workspace restaurado! As pastas apps/backend e apps/frontend estao presentes.');
  console.log('\n=== Proximos Passos ===');
  console.log('1. Instalar dependencias:');
  console.log('   npm install');
  console.log('2. Fazer setup local e subir o projeto:');
  console.log('   npm run setup:windows');
  console.log('   npm run dev:windows\n');
} else {
  console.error('\n[ERRO] Nao foi possivel restaurar os seguintes modulos:');
  missing.forEach(m => console.error(`  - ${m}`));
  console.error('\nA branch origin/work no GitHub pode ainda nao conter esses repositorios. Verifique se fez o push correto.');
  process.exit(1);
}
