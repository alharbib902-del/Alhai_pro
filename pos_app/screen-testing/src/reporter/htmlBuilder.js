/**
 * HTML Report Builder
 * Generates a fully static multi-page HTML report site.
 *
 * Pages:
 *   - report/index.html                (Dashboard)
 *   - report/categories/{slug}.html    (Category detail)
 *   - report/screens/{slug}.html       (Screen detail)
 */

const fs = require('fs');
const path = require('path');

// ─── CSS (embedded, no CDN) ───
const CSS = `
:root {
  --bg: #f8fafc; --bg2: #ffffff; --text: #0f172a; --text2: #475569;
  --border: #e2e8f0; --pass: #10b981; --pass-bg: #ecfdf5;
  --warn: #f59e0b; --warn-bg: #fffbeb; --fail: #ef4444; --fail-bg: #fef2f2;
  --primary: #3b82f6; --primary-bg: #eff6ff; --shadow: 0 1px 3px rgba(0,0,0,.1);
  --radius: 8px;
}
@media(prefers-color-scheme:dark){
  :root{--bg:#0f172a;--bg2:#1e293b;--text:#f1f5f9;--text2:#94a3b8;
  --border:#334155;--pass-bg:#064e3b;--warn-bg:#78350f;--fail-bg:#7f1d1d;
  --primary-bg:#1e3a5f;--shadow:0 1px 3px rgba(0,0,0,.4);}
}
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
  background:var(--bg);color:var(--text);line-height:1.6;}
a{color:var(--primary);text-decoration:none;}
a:hover{text-decoration:underline;}
.container{max-width:1200px;margin:0 auto;padding:20px;}

/* Header */
.header{background:var(--bg2);border-bottom:1px solid var(--border);padding:16px 0;box-shadow:var(--shadow);}
.header .container{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;}
.header h1{font-size:20px;font-weight:700;}
.header .meta{font-size:13px;color:var(--text2);}
.breadcrumb{font-size:13px;color:var(--text2);margin-bottom:20px;}
.breadcrumb a{color:var(--primary);}

/* Stats */
.stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;margin:24px 0;}
.stat-card{background:var(--bg2);border:1px solid var(--border);border-radius:var(--radius);
  padding:20px;text-align:center;box-shadow:var(--shadow);}
.stat-card .value{font-size:32px;font-weight:700;}
.stat-card .label{font-size:13px;color:var(--text2);margin-top:4px;}
.stat-card.pass .value{color:var(--pass);}
.stat-card.warn .value{color:var(--warn);}
.stat-card.fail .value{color:var(--fail);}
.stat-card.total .value{color:var(--primary);}

/* Cards */
.card{background:var(--bg2);border:1px solid var(--border);border-radius:var(--radius);
  padding:20px;margin-bottom:16px;box-shadow:var(--shadow);}
.card h2{font-size:18px;margin-bottom:12px;display:flex;align-items:center;gap:8px;}
.card h3{font-size:15px;margin:12px 0 8px;color:var(--text2);}

/* Badge */
.badge{display:inline-flex;align-items:center;padding:2px 10px;border-radius:12px;font-size:12px;font-weight:600;}
.badge.pass{background:var(--pass-bg);color:var(--pass);}
.badge.warn{background:var(--warn-bg);color:var(--warn);}
.badge.fail{background:var(--fail-bg);color:var(--fail);}

/* Table */
table{width:100%;border-collapse:collapse;margin:12px 0;}
th,td{padding:10px 12px;text-align:left;border-bottom:1px solid var(--border);font-size:14px;}
th{font-weight:600;color:var(--text2);font-size:13px;text-transform:uppercase;letter-spacing:.5px;}
tr:hover td{background:var(--primary-bg);}

/* Category grid */
.category-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:16px;margin:24px 0;}
.category-card{background:var(--bg2);border:1px solid var(--border);border-radius:var(--radius);
  padding:20px;box-shadow:var(--shadow);transition:transform .15s;}
.category-card:hover{transform:translateY(-2px);}
.category-card h3{font-size:16px;margin-bottom:8px;}
.category-card .counts{display:flex;gap:12px;margin-top:12px;}

/* Screenshots */
.screenshots{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:16px;margin:16px 0;}
.screenshot{border:1px solid var(--border);border-radius:var(--radius);overflow:hidden;}
.screenshot img{width:100%;height:auto;display:block;}
.screenshot .caption{padding:8px;font-size:12px;color:var(--text2);text-align:center;background:var(--bg);}

/* Test steps */
.test-step{padding:8px 12px;border-left:3px solid var(--border);margin:6px 0;font-size:14px;}
.test-step.pass{border-color:var(--pass);}
.test-step.warn{border-color:var(--warn);}
.test-step.fail{border-color:var(--fail);}
.test-step .meta{font-size:12px;color:var(--text2);margin-top:2px;}

/* Warnings/Limitations */
.warning-box{background:var(--warn-bg);border:1px solid var(--warn);border-radius:var(--radius);
  padding:12px;margin:8px 0;font-size:13px;}
.limitation{background:var(--bg);border:1px solid var(--border);border-radius:var(--radius);
  padding:8px 12px;margin:4px 0;font-size:13px;color:var(--text2);}

/* Console/Network */
.log-entry{font-family:monospace;font-size:12px;padding:4px 8px;border-bottom:1px solid var(--border);}
.log-entry.error{color:var(--fail);}
.log-entry.warning{color:var(--warn);}

/* Progress bar */
.progress-bar{height:8px;background:var(--border);border-radius:4px;overflow:hidden;margin:8px 0;}
.progress-bar .fill{height:100%;border-radius:4px;transition:width .3s;}
.progress-bar .fill.pass{background:var(--pass);}
.progress-bar .fill.warn{background:var(--warn);}
.progress-bar .fill.fail{background:var(--fail);}

/* Footer */
.footer{text-align:center;padding:24px;color:var(--text2);font-size:13px;margin-top:40px;
  border-top:1px solid var(--border);}

/* Arabic RTL sections */
.ar-text{direction:rtl;text-align:right;font-family:'Segoe UI','Tahoma','Arial',sans-serif;line-height:1.8;}
.ar-description{background:var(--primary-bg);border:1px solid var(--border);border-radius:var(--radius);
  padding:16px;margin:12px 0;direction:rtl;text-align:right;font-size:14px;line-height:1.9;
  font-family:'Segoe UI','Tahoma','Arial',sans-serif;color:var(--text);}
.ar-description .ar-label{font-weight:700;color:var(--primary);font-size:13px;margin-bottom:4px;}
.ar-name{font-size:15px;font-weight:600;color:var(--text);direction:rtl;}
.ar-features{direction:rtl;text-align:right;padding-right:20px;font-family:'Segoe UI','Tahoma','Arial',sans-serif;}
.ar-features li{margin:4px 0;font-size:13px;color:var(--text2);}

/* Tabs */
.theme-tabs{display:flex;gap:8px;margin:16px 0;}
.theme-tab{padding:6px 16px;border-radius:6px;border:1px solid var(--border);cursor:pointer;font-size:13px;font-weight:500;}
.theme-tab.active{background:var(--primary);color:#fff;border-color:var(--primary);}
.theme-section{display:none;}
.theme-section.active{display:block;}
`;

// ─── JS (inline, for theme tabs) ───
const INLINE_JS = `
function showTheme(t){
  document.querySelectorAll('.theme-tab').forEach(el=>{el.classList.toggle('active',el.dataset.theme===t)});
  document.querySelectorAll('.theme-section').forEach(el=>{el.classList.toggle('active',el.dataset.theme===t)});
}
document.addEventListener('DOMContentLoaded',()=>{
  const first=document.querySelector('.theme-tab');
  if(first)showTheme(first.dataset.theme);
});
`;

// ─── Helpers ───
function statusBadge(status) {
  const icon = status === 'PASS' ? '&#10004;' : status === 'WARN' ? '&#9888;' : '&#10006;';
  return `<span class="badge ${status.toLowerCase()}">${icon} ${status}</span>`;
}

function pageTemplate(title, breadcrumbs, content, baseHref = '') {
  return `<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${title} - Alhai POS Testing</title>
<style>${CSS}</style>
<script>${INLINE_JS}<\/script>
</head>
<body>
<div class="header">
  <div class="container">
    <h1>Alhai POS Screen Testing</h1>
    <div class="meta">Agent-Based Testing System</div>
  </div>
</div>
<div class="container">
  <div class="breadcrumb">${breadcrumbs}</div>
  ${content}
</div>
<div class="footer">
  Generated by Alhai POS Screen Testing System &bull; ${new Date().toLocaleString()}
</div>
</body>
</html>`;
}

// ─── Dashboard (index.html) ───
function buildDashboard(results) {
  const s = results.summary;
  const total = s.passCount + s.warnCount + s.failCount;
  const passRate = total > 0 ? ((s.passCount / total) * 100).toFixed(1) : 0;

  let categoriesHTML = '';
  // Group by category (merge themes)
  const categoryMap = {};
  for (const cat of results.categories) {
    if (!categoryMap[cat.categorySlug]) {
      categoryMap[cat.categorySlug] = {
        slug: cat.categorySlug,
        name: cat.categoryName,
        nameAr: cat.categoryNameAr,
        descriptionAr: cat.categoryDescriptionAr || '',
        themes: {},
        totalScreens: cat.totalScreens,
      };
    }
    categoryMap[cat.categorySlug].themes[cat.theme] = {
      pass: cat.passCount,
      warn: cat.warnCount,
      fail: cat.failCount,
      duration: cat.duration,
    };
  }

  for (const [slug, cat] of Object.entries(categoryMap)) {
    let countsHTML = '';
    for (const [theme, counts] of Object.entries(cat.themes)) {
      const catTotal = counts.pass + counts.warn + counts.fail;
      countsHTML += `<div style="font-size:12px"><strong>${theme}:</strong>
        <span style="color:var(--pass)">${counts.pass}P</span> /
        <span style="color:var(--warn)">${counts.warn}W</span> /
        <span style="color:var(--fail)">${counts.fail}F</span>
        <span style="color:var(--text2)">(${(counts.duration/1000).toFixed(1)}s)</span></div>`;
    }
    categoriesHTML += `
    <a href="categories/${slug}.html" class="category-card" style="text-decoration:none;color:inherit;">
      <h3>${cat.name} <span style="font-size:13px;color:var(--text2)">${cat.nameAr}</span></h3>
      <div style="font-size:14px;color:var(--text2)">${cat.totalScreens} screens</div>
      ${cat.descriptionAr ? `<div class="ar-description" style="margin:8px 0;font-size:12px;padding:8px 12px">${cat.descriptionAr}</div>` : ''}
      <div class="counts" style="flex-direction:column;gap:4px">${countsHTML}</div>
    </a>`;
  }

  const content = `
    <h2 style="margin-bottom:8px">Dashboard</h2>
    <p style="color:var(--text2);margin-bottom:16px">
      Run: ${results.meta.timestamp} &bull; Duration: ${(results.meta.duration/1000).toFixed(1)}s
      &bull; Viewport: ${results.meta.viewport.width}x${results.meta.viewport.height}
      &bull; Themes: ${results.meta.themes.join(', ')}
    </p>

    <div class="stats-grid">
      <div class="stat-card total"><div class="value">${total}</div><div class="label">Total Screens</div></div>
      <div class="stat-card pass"><div class="value">${s.passCount}</div><div class="label">Passed</div></div>
      <div class="stat-card warn"><div class="value">${s.warnCount}</div><div class="label">Warnings</div></div>
      <div class="stat-card fail"><div class="value">${s.failCount}</div><div class="label">Failed</div></div>
    </div>

    <div class="card">
      <h2>Pass Rate</h2>
      <div style="font-size:28px;font-weight:700;color:${parseFloat(passRate)>=80?'var(--pass)':parseFloat(passRate)>=50?'var(--warn)':'var(--fail)'}">${passRate}%</div>
      <div class="progress-bar" style="margin-top:8px">
        <div class="fill pass" style="width:${passRate}%"></div>
      </div>
    </div>

    <h2 style="margin:24px 0 12px">Categories (Agents)</h2>
    <div class="category-grid">${categoriesHTML}</div>

    <div class="card">
      <h2>All Screens Overview</h2>
      <table>
        <thead><tr><th>Screen</th><th>الاسم</th><th>Category</th><th>Path</th><th>Status (per theme)</th></tr></thead>
        <tbody>
        ${results.categories.map(cat =>
          cat.screens.map(scr => `
            <tr>
              <td><a href="screens/${scr.screenSlug}.html">${scr.name}</a></td>
              <td class="ar-name" style="font-size:13px">${scr.nameAr || ''}</td>
              <td>${cat.categoryName}</td>
              <td style="font-family:monospace;font-size:13px">${scr.path}</td>
              <td>${statusBadge(scr.overallStatus)} <span style="font-size:11px;color:var(--text2)">${cat.theme}</span></td>
            </tr>
          `).join('')
        ).join('')}
        </tbody>
      </table>
    </div>
  `;

  return pageTemplate('Dashboard', '<a href="index.html">Home</a>', content);
}

// ─── Category Page ───
function buildCategoryPage(categorySlug, results) {
  const categoryResults = results.categories.filter(c => c.categorySlug === categorySlug);
  if (categoryResults.length === 0) return '';

  const first = categoryResults[0];
  const themes = [...new Set(categoryResults.map(c => c.theme))];

  let tabsHTML = themes.map(t => `<div class="theme-tab" data-theme="${t}" onclick="showTheme('${t}')">${t}</div>`).join('');

  let themeSections = '';
  for (const cat of categoryResults) {
    let screensHTML = cat.screens.map(scr => `
      <tr>
        <td><a href="../screens/${scr.screenSlug}.html">${scr.name}</a>${scr.nameAr ? `<br><span class="ar-name" style="font-size:12px;color:var(--text2)">${scr.nameAr}</span>` : ''}</td>
        <td style="font-family:monospace;font-size:13px">${scr.path}</td>
        <td>${statusBadge(scr.overallStatus)}</td>
        <td>${(scr.duration/1000).toFixed(1)}s</td>
        <td>${scr.consoleLogs.length > 0 ? `<span style="color:var(--warn)">${scr.consoleLogs.length}</span>` : '-'}</td>
        <td>${scr.networkErrors.length > 0 ? `<span style="color:var(--fail)">${scr.networkErrors.length}</span>` : '-'}</td>
      </tr>
    `).join('');

    themeSections += `
    <div class="theme-section" data-theme="${cat.theme}">
      <div class="stats-grid">
        <div class="stat-card pass"><div class="value">${cat.passCount}</div><div class="label">Passed</div></div>
        <div class="stat-card warn"><div class="value">${cat.warnCount}</div><div class="label">Warnings</div></div>
        <div class="stat-card fail"><div class="value">${cat.failCount}</div><div class="label">Failed</div></div>
        <div class="stat-card total"><div class="value">${(cat.duration/1000).toFixed(1)}s</div><div class="label">Duration</div></div>
      </div>
      <table>
        <thead><tr><th>Screen</th><th>Path</th><th>Status</th><th>Duration</th><th>Console</th><th>Network</th></tr></thead>
        <tbody>${screensHTML}</tbody>
      </table>
    </div>`;
  }

  const categoryDescAr = first.categoryDescriptionAr || '';
  const content = `
    <h2>${first.categoryName} <span style="font-size:16px;color:var(--text2)">${first.categoryNameAr}</span></h2>
    <p style="color:var(--text2);margin:8px 0">${first.totalScreens} screens</p>
    ${categoryDescAr ? `<div class="ar-description"><div class="ar-label">وصف القسم</div>${categoryDescAr}</div>` : ''}
    <div class="theme-tabs">${tabsHTML}</div>
    ${themeSections}
  `;

  const breadcrumbs = `<a href="../index.html">Home</a> / ${first.categoryName}`;
  return pageTemplate(first.categoryName, breadcrumbs, content);
}

// ─── Screen Page ───
function buildScreenPage(screenSlug, results) {
  // Find all instances of this screen across themes
  const screenInstances = [];
  for (const cat of results.categories) {
    for (const scr of cat.screens) {
      if (scr.screenSlug === screenSlug) {
        screenInstances.push({ ...scr, categoryName: cat.categoryName, categorySlug: cat.categorySlug });
      }
    }
  }

  if (screenInstances.length === 0) return '';
  const first = screenInstances[0];
  const themes = [...new Set(screenInstances.map(s => s.theme))];

  let tabsHTML = themes.map(t => `<div class="theme-tab" data-theme="${t}" onclick="showTheme('${t}')">${t}</div>`).join('');

  let themeSections = '';
  for (const scr of screenInstances) {
    // Features
    let featuresHTML = scr.features.map(f => `<li>${f}</li>`).join('');

    // Expected Behaviors
    let behaviorsHTML = scr.expectedBehaviors.map(b => `<li>${b}</li>`).join('');

    // Scenarios
    let scenariosHTML = '';
    for (const scenario of scr.scenarios) {
      let setupNotes = (scenario.setupNotes || []).map(n => `<div class="warning-box">${n}</div>`).join('');
      let testsHTML = scenario.tests.map(t => `
        <div class="test-step ${t.status.toLowerCase()}">
          <strong>${t.stepName}</strong> ${statusBadge(t.status)}
          <div class="meta">
            Action: ${t.action} | Selector: ${t.selectorMethod} (${t.selectorUsed}) | ${t.duration}ms
            ${t.warnings.length > 0 ? '<br>Warnings: ' + t.warnings.join('; ') : ''}
            ${t.error ? '<br><span style="color:var(--fail)">Error: ' + t.error + '</span>' : ''}
            ${t.screenshot ? '<br><a href="../' + t.screenshot + '">Screenshot</a>' : ''}
          </div>
        </div>
      `).join('');

      scenariosHTML += `
        <div class="card" style="margin-left:16px">
          <h3>${scenario.scenarioName} ${statusBadge(scenario.status)}</h3>
          ${scenario.dataState ? `<div style="font-size:12px;color:var(--text2)">Data state: ${scenario.dataState}</div>` : ''}
          ${setupNotes}
          ${testsHTML}
        </div>
      `;
    }

    // Screenshots
    let screenshotsHTML = '';
    if (scr.screenshots && scr.screenshots.length > 0) {
      screenshotsHTML = `<h3>Screenshots</h3><div class="screenshots">` +
        scr.screenshots.map(ss => `
          <div class="screenshot">
            <img src="../${ss.path}" alt="${ss.type}" loading="lazy">
            <div class="caption">${ss.type}${ss.step ? ' - ' + ss.step : ''}</div>
          </div>
        `).join('') + '</div>';
    }

    // Console logs
    let consoleLogs = '';
    if (scr.consoleLogs.length > 0) {
      consoleLogs = `<h3>Console Logs (${scr.consoleLogs.length})</h3>` +
        scr.consoleLogs.map(l => `<div class="log-entry ${l.type}">[${l.type}] ${l.text}</div>`).join('');
    }

    // Network errors
    let networkErrors = '';
    if (scr.networkErrors.length > 0) {
      networkErrors = `<h3>Network Errors (${scr.networkErrors.length})</h3>` +
        scr.networkErrors.map(e => `<div class="log-entry error">${e.method} ${e.url} - ${e.failure}</div>`).join('');
    }

    // Limitations
    let limitationsHTML = '';
    if (scr.limitations && scr.limitations.length > 0) {
      limitationsHTML = `<h3>Known Limitations</h3>` +
        scr.limitations.map(l => `<div class="limitation">${l}</div>`).join('');
    }

    themeSections += `
    <div class="theme-section" data-theme="${scr.theme}">
      <div class="stats-grid">
        <div class="stat-card ${scr.overallStatus.toLowerCase()}">
          <div class="value">${scr.overallStatus}</div><div class="label">Status</div>
        </div>
        <div class="stat-card total">
          <div class="value">${(scr.duration/1000).toFixed(1)}s</div><div class="label">Duration</div>
        </div>
      </div>

      <div class="card">
        <h2>Features</h2>
        <ul style="padding-left:20px">${featuresHTML}</ul>
      </div>

      <div class="card">
        <h2>Expected Behaviors</h2>
        <ul style="padding-left:20px">${behaviorsHTML}</ul>
      </div>

      <div class="card">
        <h2>Test Scenarios</h2>
        ${scenariosHTML}
      </div>

      ${screenshotsHTML ? `<div class="card">${screenshotsHTML}</div>` : ''}
      ${consoleLogs ? `<div class="card">${consoleLogs}</div>` : ''}
      ${networkErrors ? `<div class="card">${networkErrors}</div>` : ''}
      ${limitationsHTML ? `<div class="card">${limitationsHTML}</div>` : ''}
    </div>`;
  }

  const screenNameAr = first.nameAr || '';
  const screenDescAr = first.descriptionAr || '';
  const content = `
    <h2>${first.name} ${screenNameAr ? `<span class="ar-name" style="font-size:16px;margin-right:8px">${screenNameAr}</span>` : ''}</h2>
    <p style="color:var(--text2);margin:4px 0">
      Path: <code style="background:var(--bg);padding:2px 6px;border-radius:4px">${first.path}</code>
    </p>
    ${screenDescAr ? `<div class="ar-description"><div class="ar-label">وصف الشاشة</div>${screenDescAr}</div>` : ''}
    <div class="theme-tabs">${tabsHTML}</div>
    ${themeSections}
  `;

  const breadcrumbs = `<a href="../index.html">Home</a> / <a href="../categories/${first.categorySlug}.html">${first.categoryName}</a> / ${first.name}`;
  return pageTemplate(first.name, breadcrumbs, content);
}

// ─── Build All ───
function buildReport(results, reportDir) {
  // 1. CSS file
  const cssDir = path.join(reportDir, 'assets', 'css');
  fs.mkdirSync(cssDir, { recursive: true });
  fs.writeFileSync(path.join(cssDir, 'style.css'), CSS);

  // 2. Dashboard
  const dashboardHTML = buildDashboard(results);
  fs.writeFileSync(path.join(reportDir, 'index.html'), dashboardHTML);
  console.log('  ✅ index.html');

  // 3. Category pages
  const categorySlugs = [...new Set(results.categories.map(c => c.categorySlug))];
  const catDir = path.join(reportDir, 'categories');
  fs.mkdirSync(catDir, { recursive: true });
  for (const slug of categorySlugs) {
    const html = buildCategoryPage(slug, results);
    if (html) {
      fs.writeFileSync(path.join(catDir, `${slug}.html`), html);
      console.log(`  ✅ categories/${slug}.html`);
    }
  }

  // 4. Screen pages
  const screenSlugs = new Set();
  for (const cat of results.categories) {
    for (const scr of cat.screens) {
      screenSlugs.add(scr.screenSlug);
    }
  }
  const scrDir = path.join(reportDir, 'screens');
  fs.mkdirSync(scrDir, { recursive: true });
  for (const slug of screenSlugs) {
    const html = buildScreenPage(slug, results);
    if (html) {
      fs.writeFileSync(path.join(scrDir, `${slug}.html`), html);
      console.log(`  ✅ screens/${slug}.html`);
    }
  }

  console.log(`  📁 Report built: ${reportDir}`);
}

module.exports = { buildReport };
