const fs = require('fs');
const { execSync } = require('child_process');

function run(cmd) {
  try {
    return execSync(cmd, { stdio: 'pipe' }).toString().trim();
  } catch {
    return null;
  }
}

const missing = [];
if (!fs.existsSync('apps/backend/package.json')) missing.push('apps/backend');
if (!fs.existsSync('apps/frontend/package.json')) missing.push('apps/frontend');

if (missing.length > 0) {
  console.error('\n[ERRO] Estrutura incompleta! Os seguintes modulos estao ausentes ou sem package.json:');
  missing.forEach(m => console.error(`  - ${m}`));
  
  console.error('\nDiagnostico de branch e repositorio:');
  const currentBranch = run('git branch --show-current');
  console.error(`  Branch atual: ${currentBranch || 'Desconhecida'}`);
  
  const hasOrigin = run('git remote -v');
  const hasOriginWork = hasOrigin ? run('git ls-remote --heads origin work') : null;
  
  if (currentBranch === 'main' && hasOriginWork) {
    console.error('\n[SOLUCAO] Voce esta na branch "main", mas o codigo pode estar na branch "work".');
    console.error('Execute os seguintes comandos para recuperar o projeto:');
    if (process.platform === 'win32') {
      console.error('\n  git fetch origin work');
      console.error('  git checkout work');
      console.error('  npm install');
      console.error('  npm run setup:windows');
    } else {
      console.error('\n  git fetch origin work');
      console.error('  git checkout work');
      console.error('  npm install');
      console.error('  npm run setup:windows'); // they might have a different setup script for linux but setup:windows is what was provided
    }
  } else {
    console.error('\n[SOLUCAO] Verifique se o repositorio foi clonado por completo ou baixe o zip novamente.');
  }
  
  console.error();
  process.exit(1);
}
