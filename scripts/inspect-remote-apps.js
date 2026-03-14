const { execSync } = require('child_process');

function runCapture(cmd) {
  try {
    return execSync(cmd, { stdio: 'pipe' }).toString().trim();
  } catch (e) {
    return null;
  }
}

console.log('\n=== Inspecionando apps nos remotes ===\n');

console.log('Fazendo fetch remoto...');
runCapture('git fetch origin work');
runCapture('git fetch origin "+refs/pull/*/head:refs/remotes/origin/pr/*"');

// Verificar origin/work
const workTree = runCapture('git ls-tree origin/work -- apps/backend apps/frontend');
console.log('\n--- origin/work ---');
if (workTree && workTree.length > 0) {
  const hasBackend = workTree.includes('apps/backend');
  const hasFrontend = workTree.includes('apps/frontend');
  console.log(`  apps/backend:  ${hasBackend ? '✅ presente' : '❌ ausente'}`);
  console.log(`  apps/frontend: ${hasFrontend ? '✅ presente' : '❌ ausente'}`);
} else {
  console.log('  ❌ Nenhum app encontrado em origin/work');
}

// Verificar PRs
console.log('\n--- Pull Requests (origin/pr/*) ---');
let prRefsRaw = null;
try {
  prRefsRaw = execSync('git for-each-ref --format="%(refname:short)" refs/remotes/origin/pr/', { encoding: 'utf8' }).trim();
} catch (e) {}

if (prRefsRaw && prRefsRaw.length > 0) {
  const prRefs = prRefsRaw.split('\n').filter(Boolean);
  for (const prRef of prRefs) {
    const prTree = runCapture(`git ls-tree ${prRef} -- apps/backend apps/frontend`);
    if (prTree && prTree.length > 0) {
      const hasBackend = prTree.includes('apps/backend');
      const hasFrontend = prTree.includes('apps/frontend');
      console.log(`  ${prRef}:`);
      console.log(`    apps/backend:  ${hasBackend ? '✅ presente' : '❌ ausente'}`);
      console.log(`    apps/frontend: ${hasFrontend ? '✅ presente' : '❌ ausente'}`);
    } else {
      console.log(`  ${prRef}: ❌ sem apps/`);
    }
  }
} else {
  console.log('  Nenhum PR encontrado');
}

console.log('\nSe nenhuma ref tiver os apps, você precisa fazer push do seu ambiente de origem:');
console.log('  git add apps/');
console.log('  git commit -m "feat: adicionar apps"');
console.log('  git push origin work\n');
