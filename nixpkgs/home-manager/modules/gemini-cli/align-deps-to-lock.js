// Realign exact-pinned dependency versions in every workspace package.json with
// the version the committed package-lock.json actually resolved.
//
// Upstream gemini-cli releases sometimes pin a dependency to an exact version
// (e.g. "tar": "7.5.8") that is later unpublished/yanked from npm, while the
// lockfile records a still-published version (e.g. "7.5.11"). `npm ci` then
// tries to fetch the missing exact version and fails with ETARGET. We only
// touch exact full-semver pins, leaving ranges (^, ~, x, major-only, workspace:,
// file:, etc.) untouched.
const fs = require("fs");

const lock = JSON.parse(fs.readFileSync("package-lock.json", "utf8"));
const pkgs = lock.packages || {};

// Exact pin = a bare full semver "X.Y.Z[...]" with no range operator.
const isExactPin = (spec) => /^\d+\.\d+\.\d+/.test(spec);

function resolvedVersion(workspaceKey, dep) {
  const candidates = [
    `${workspaceKey}/node_modules/${dep}`,
    `node_modules/${dep}`,
  ];
  for (const key of candidates) {
    if (pkgs[key] && pkgs[key].version) return pkgs[key].version;
  }
  return null;
}

const fields = [
  "dependencies",
  "optionalDependencies",
  "devDependencies",
  "peerDependencies",
];

let totalFixed = 0;

for (const key of Object.keys(pkgs)) {
  // Only workspace roots (and the repo root ""), never nested node_modules.
  if (key.includes("/node_modules/")) continue;
  const file = key === "" ? "package.json" : `${key}/package.json`;
  if (!fs.existsSync(file)) continue;

  const pj = JSON.parse(fs.readFileSync(file, "utf8"));
  let changed = false;

  for (const field of fields) {
    const deps = pj[field];
    if (!deps) continue;
    for (const [dep, spec] of Object.entries(deps)) {
      if (typeof spec !== "string" || !isExactPin(spec)) continue;
      const rv = resolvedVersion(key, dep);
      if (rv && rv !== spec) {
        console.log(`align ${file}: ${dep} ${spec} -> ${rv}`);
        deps[dep] = rv;
        changed = true;
        totalFixed++;
      }
    }
  }

  if (changed) fs.writeFileSync(file, JSON.stringify(pj, null, 2) + "\n");
}

console.log(`align-deps-to-lock: realigned ${totalFixed} exact pin(s)`);
