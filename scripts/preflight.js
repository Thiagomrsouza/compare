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
// --- Validações de identidade do frontend ---
const identityErrors = [];

// 1. Checar se index.html tem title começando com "Compare"
const indexHtml = fs.existsSync('apps/frontend/index.html')
  ? fs.readFileSync('apps/frontend/index.html', 'utf8')
  : '';

const titleMatch = indexHtml.match(/<title>(.*?)<\/title>/i);
const title = titleMatch ? titleMatch[1].trim() : '';
if (!title.toLowerCase().startsWith('compare')) {
  identityErrors.push(`apps/frontend/index.html: <title> deve começar com "Compare" (atual: "${title}")`);
}

// 2. Checar se a rota /compare existe no backend
const backendSrc = fs.existsSync('apps/backend/src/index.js')
  ? fs.readFileSync('apps/backend/src/index.js', 'utf8')
  : '';
if (!backendSrc.includes('/compare')) {
  identityErrors.push('apps/backend/src/index.js: rota /compare não encontrada');
}

if (identityErrors.length > 0) {
  console.error('\n[AVISO] Identidade do projeto não completamente validada:');
  identityErrors.forEach(e => console.error(`  - ${e}`));
  console.error('\nVerifique se o frontend e backend estão configurados corretamente para o projeto Compare.');
  console.error('Isso pode indicar que o servidor Vite padrão foi carregado. Verifique apps/frontend/index.html e apps/backend/src/index.js.\n');
  process.exit(1);
}

console.log('[OK] Preflight completo. Estrutura e identidade do projeto validadas.\n');
