const fs = require('fs');
const { execSync } = require('child_process');

const list = JSON.parse(fs.readFileSync('Sahih_Hadiths_100.json', 'utf8'));

const generateHtml = (hadiths) => {
  return `<!DOCTYPE html>
<html lang="ku" dir="rtl">
<head>
<meta charset="UTF-8">
<title>١٠٠ فەرموودەی صەحیحی پێغەمبەری خودا (ﷺ) بە وردەکاری پلەی فەرموودە</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&family=Noto+Naskh+Arabic:wght@400;600;700&family=Inter:wght@400;500;600;700&display=swap');

  @page {
    size: A4 portrait;
    margin: 1.2cm 1.2cm 1.5cm 1.2cm;
    @bottom-right {
      content: counter(page);
    }
  }

  * {
    box-sizing: border-box;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  body {
    font-family: 'Noto Naskh Arabic', 'Amiri', 'Segoe UI', Tahoma, sans-serif;
    background-color: #f8fafc;
    color: #0f172a;
    margin: 0;
    padding: 24px;
    line-height: 1.7;
  }

  .cover-header {
    background: linear-gradient(135deg, #064e3b 0%, #047857 50%, #065f46 100%);
    color: #ffffff;
    border-radius: 16px;
    padding: 36px 24px;
    text-align: center;
    margin-bottom: 28px;
    box-shadow: 0 10px 25px -5px rgba(6, 78, 59, 0.3);
    border: 2px solid #d97706;
  }

  .bismillah {
    font-family: 'Amiri', serif;
    font-size: 28px;
    color: #fef08a;
    margin-bottom: 12px;
    letter-spacing: 1px;
  }

  .main-title {
    font-size: 32px;
    font-weight: 700;
    margin: 0 0 10px 0;
    color: #ffffff;
  }

  .subtitle {
    font-size: 16.5px;
    color: #d1fae5;
    margin-bottom: 16px;
    font-weight: 500;
  }

  .meta-badges {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
  }

  .meta-badge {
    background: rgba(255, 255, 255, 0.15);
    border: 1px solid rgba(255, 255, 255, 0.3);
    padding: 5px 14px;
    border-radius: 9999px;
    font-size: 13px;
    color: #fef9c3;
  }

  .stats-summary {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 18px 24px;
    margin-bottom: 24px;
    display: flex;
    justify-content: space-around;
    text-align: center;
    box-shadow: 0 2px 4px rgba(0,0,0,0.04);
  }

  .stat-item .num {
    font-size: 26px;
    font-weight: 700;
    color: #047857;
  }

  .stat-item .label {
    font-size: 13.5px;
    color: #64748b;
  }

  .hadith-card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
    padding: 22px 24px;
    margin-bottom: 22px;
    page-break-inside: avoid;
    break-inside: avoid;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
    border-right: 5px solid #059669;
    position: relative;
  }

  .hadith-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
    border-bottom: 1px dashed #e2e8f0;
    padding-bottom: 10px;
  }

  .hadith-id-chapter {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .hadith-num {
    background: #047857;
    color: #ffffff;
    font-weight: 700;
    font-size: 13.5px;
    width: 34px;
    height: 34px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
  }

  .chapter-pill {
    background: #ecfdf5;
    color: #065f46;
    font-weight: 600;
    font-size: 13.5px;
    padding: 4px 12px;
    border-radius: 6px;
    border: 1px solid #a7f3d0;
  }

  .grade-badge {
    background: #fef3c7;
    color: #92400e;
    font-weight: 700;
    font-size: 12.5px;
    padding: 4px 12px;
    border-radius: 20px;
    border: 1px solid #fde68a;
    display: inline-flex;
    align-items: center;
    gap: 4px;
  }

  .grade-badge.muttafaq {
    background: #dcfce7;
    color: #166534;
    border-color: #86efac;
  }

  .grade-badge.hasan {
    background: #e0f2fe;
    color: #0369a1;
    border-color: #bae6fd;
  }

  .narrator {
    color: #475569;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 8px;
  }

  .arabic-text {
    font-family: 'Amiri', 'Traditional Arabic', serif;
    font-size: 21.5px;
    font-weight: 700;
    color: #064e3b;
    line-height: 2.1;
    text-align: justify;
    background: #f0fdf4;
    padding: 14px 18px;
    border-radius: 10px;
    margin-bottom: 12px;
    border-right: 4px solid #10b981;
  }

  .kurdish-section {
    margin-bottom: 10px;
  }

  .section-label {
    font-size: 12px;
    font-weight: 700;
    color: #059669;
    text-transform: uppercase;
    margin-bottom: 2px;
  }

  .kurdish-text {
    font-size: 15.5px;
    color: #1e293b;
    line-height: 1.8;
    text-align: justify;
  }

  .english-section {
    direction: ltr;
    text-align: left;
    margin-top: 10px;
    padding-top: 10px;
    border-top: 1px solid #f1f5f9;
  }

  .english-label {
    font-family: 'Inter', sans-serif;
    font-size: 11px;
    font-weight: 700;
    color: #64748b;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }

  .english-text {
    font-family: 'Inter', -apple-system, sans-serif;
    font-size: 13.5px;
    color: #334155;
    line-height: 1.6;
    margin-top: 2px;
  }

  .hadith-footer {
    margin-top: 12px;
    padding-top: 8px;
    border-top: 1px dashed #e2e8f0;
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    color: #64748b;
  }

  .source-tag {
    font-weight: 600;
    color: #047857;
  }

  .footer-note {
    text-align: center;
    color: #64748b;
    font-size: 13px;
    margin-top: 35px;
    padding: 18px;
    border-top: 1px solid #cbd5e1;
  }

  @media print {
    body {
      background-color: #ffffff;
      padding: 0;
    }
    .hadith-card {
      box-shadow: none;
      border: 1px solid #cbd5e1;
      margin-bottom: 18px;
    }
  }
</style>
</head>
<body>

<div class="cover-header">
  <div class="bismillah">بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ</div>
  <h1 class="main-title">کۆکراوەی ١٠٠ فەرموودەی مەقبوول (صەحیح و حەسەن)ـی پێغەمبەر ﷺ</h1>
  <div class="subtitle">بە دەستنیشانکردنی دەقیقی پلەی زانستی هەر فەرموودەیەک: صحيح متفق عليه، صحيح البخاري، صحيح مسلم، حسن صحيح</div>
  <div class="meta-badges">
    <span class="meta-badge">✓ ٨٩ فەرموودە: پلەی سەحیحی ڕەها (متفق عليه / بخاري / مسلم)</span>
    <span class="meta-badge">✓ ١١ فەرموودە: پلەی حەسەنی دروست (حسن صحيح / حسن بشواهده)</span>
    <span class="meta-badge">✓ هیچ فەرموودەیەکی لاواز (ضعيف) یان هەڵبەستراوی تێدا نییە</span>
  </div>
</div>

<div class="stats-summary">
  <div class="stat-item">
    <div class="num">٤٥</div>
    <div class="label">مُتَّفَقٌ عَلَيْهِ (بوخاری و موسلیم)</div>
  </div>
  <div class="stat-item">
    <div class="num">٣٥</div>
    <div class="label">صحیح بە تەنها (بوخاری یان موسلیم)</div>
  </div>
  <div class="stat-item">
    <div class="num">١١</div>
    <div class="label">حسن صحیح (سونەنەکان)</div>
  </div>
  <div class="stat-item">
    <div class="num">٩</div>
    <div class="label">صحيح بشواهده / لغيره</div>
  </div>
</div>

<div class="hadiths-container">
  ${hadiths.map(h => {
    let badgeClass = '';
    if (h.grade.includes('متفق عليه')) badgeClass = 'muttafaq';
    else if (h.grade.startsWith('حسن')) badgeClass = 'hasan';
    return `
  <div class="hadith-card" id="hadith-${h.id}">
    <div class="hadith-top">
      <div class="hadith-id-chapter">
        <div class="hadith-num">${h.id}</div>
        <div class="chapter-pill">${h.chapter} • ${h.chapter_en}</div>
      </div>
      <div class="grade-badge ${badgeClass}">
        <span>★ ${h.grade}</span>
      </div>
    </div>

    <div class="narrator">${h.narrator_ar}</div>

    <div class="arabic-text">${h.text_ar}</div>

    <div class="kurdish-section">
      <div class="section-label">وەرگێڕان و مانای کوردی:</div>
      <div class="kurdish-text">${h.text_ku}</div>
    </div>

    <div class="english-section">
      <div class="english-label">English Translation:</div>
      <div class="english-text">${h.text_en}</div>
    </div>

    <div class="hadith-footer">
      <div class="source-tag">سەرچاوە و تەخریج: ${h.source}</div>
      <div>Nada Zikr Hadith Database</div>
    </div>
  </div>
  `;
  }).join('')}
</div>

<div class="footer-note">
  کۆکراوەی ١٠٠ فەرموودەی مەقبوول (صەحیح و حەسەن)ـی پێغەمبەری خودا ﷺ — بەرهەمهێنراوە بۆ نەرمەکاڵای «نەدا - زیکر و قورئان» (Nada Zikr)
</div>

</body>
</html>`;
};

fs.writeFileSync('Sahih_Hadiths_100.html', generateHtml(list), 'utf8');
console.log('Saved updated Sahih_Hadiths_100.html with specific grades!');
