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
  
  // always suggest the repair workspace command
  console.error('\n[SOLUCAO] Para tentar restaurar o workspace (baixar apps da branch remota work automagicamente),');
  console.error('execute o comando de auto-reparo:');
  console.error('\n  npm run repair:workspace\n');
  
  console.error();
  process.exit(1);
}
