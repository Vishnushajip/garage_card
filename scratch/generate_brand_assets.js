const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const CHROME_PATH = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";

const brandingDir = path.join(__dirname, '..', 'assets', 'branding');
const webDir = path.join(__dirname, '..', 'web');
const webIconsDir = path.join(webDir, 'icons');
const resDir = path.join(__dirname, '..', 'android', 'app', 'src', 'main', 'res');

[brandingDir, webIconsDir].forEach(dir => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

// 1. Vector Symbol SVG (ViewBox 0 0 512 512)
// Designed with precision automotive geometry: Stylized 'W' with integrated spanner wrench head and checkmark dynamic ascent.
function getSymbolSvg(isWhiteOnRed = false, isPureWhite = false) {
  const primaryRed = "#DC2626";
  const darkRed = "#991B1B";
  const brightRed = "#EF4444";
  
  if (isWhiteOnRed) {
    // App icon / Badge version: Red gradient background with crisp white icon
    return `<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGrad" x1="0" y1="0" x2="512" y2="512" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="${brightRed}"/>
      <stop offset="45%" stop-color="${primaryRed}"/>
      <stop offset="100%" stop-color="${darkRed}"/>
    </linearGradient>
    <filter id="badgeShadow" x="0" y="8" width="512" height="512" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
      <feDropShadow dx="0" dy="16" stdDeviation="24" flood-color="#7F1D1D" flood-opacity="0.35"/>
    </filter>
  </defs>
  <rect width="512" height="512" rx="128" fill="url(#bgGrad)"/>
  
  <!-- Subtle automotive geometric accent circle -->
  <circle cx="256" cy="256" r="190" stroke="white" stroke-opacity="0.08" stroke-width="2"/>
  
  <!-- WeFix Iconic Monogram Emblem -->
  <!-- Left Wing -->
  <path d="M 112 168 C 112 150 128 138 144 146 L 206 342 C 212 360 198 376 180 376 C 168 376 158 368 152 356 L 98 186 C 94 176 98 168 112 168 Z" fill="white"/>
  
  <!-- Center Spanner / Wrench V-Crest -->
  <path d="M 186 362 L 232 236 C 235 228 244 222 254 222 C 255 222 257 222 258 222 C 268 222 277 228 280 236 L 326 362 C 332 378 318 392 302 392 C 290 392 280 384 276 372 L 256 312 L 236 372 C 232 384 222 392 210 392 C 194 392 180 378 186 362 Z" fill="white"/>
  
  <!-- Precision Wrench Jaw Aperture Detail in Center -->
  <path d="M 238 180 C 238 170 246 162 256 162 C 266 162 274 170 274 180 L 274 206 C 268 202 262 200 256 200 C 250 200 244 202 238 206 Z" fill="white"/>
  <circle cx="256" cy="180" r="16" fill="url(#bgGrad)"/>
  
  <!-- Right Wing / Dynamic Checkmark Ascender -->
  <path d="M 306 342 L 396 142 C 402 128 418 122 430 130 C 442 138 444 154 438 168 L 332 364 C 326 376 314 382 302 380 C 292 378 286 368 290 358 L 306 342 Z" fill="white"/>
  
  <!-- Speed Spark Accent -->
  <circle cx="432" cy="132" r="14" fill="#FEF08A"/>
</svg>`;
  } else {
    // Transparent symbol: can be Red or Pure White
    const fillCol = isPureWhite ? "#FFFFFF" : primaryRed;
    const accentCol = isPureWhite ? "#FDE047" : "#DC2626";
    const bgCut = isPureWhite ? "#0F172A" : "#FFFFFF";
    
    return `<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Left Wing -->
  <path d="M 112 168 C 112 150 128 138 144 146 L 206 342 C 212 360 198 376 180 376 C 168 376 158 368 152 356 L 98 186 C 94 176 98 168 112 168 Z" fill="${fillCol}"/>
  
  <!-- Center Spanner / Wrench V-Crest -->
  <path d="M 186 362 L 232 236 C 235 228 244 222 254 222 C 255 222 257 222 258 222 C 268 222 277 228 280 236 L 326 362 C 332 378 318 392 302 392 C 290 392 280 384 276 372 L 256 312 L 236 372 C 232 384 222 392 210 392 C 194 392 180 378 186 362 Z" fill="${fillCol}"/>
  
  <!-- Precision Wrench Detail -->
  <path d="M 238 180 C 238 170 246 162 256 162 C 266 162 274 170 274 180 L 274 206 C 268 202 262 200 256 200 C 250 200 244 202 238 206 Z" fill="${fillCol}"/>
  <circle cx="256" cy="180" r="16" fill="${isPureWhite ? 'transparent' : 'white'}"/>
  
  <!-- Right Wing / Dynamic Checkmark Ascender -->
  <path d="M 306 342 L 396 142 C 402 128 418 122 430 130 C 442 138 444 154 438 168 L 332 364 C 326 376 314 382 302 380 C 292 378 286 368 290 358 L 306 342 Z" fill="${fillCol}"/>
  
  <circle cx="432" cy="132" r="14" fill="${accentCol}"/>
</svg>`;
  }
}

// 2. Full Horizontal Logo with Wordmark SVG (ViewBox 0 0 900 260)
function getFullLogoSvg(theme = 'light') {
  const isDark = theme === 'dark'; // dark bg => white text
  const primaryRed = "#DC2626";
  const weTextColor = isDark ? "#FFFFFF" : "#0F172A";
  const fixTextColor = isDark ? "#FFFFFF" : primaryRed;
  const tagColor = isDark ? "#94A3B8" : "#64748B";
  const dotColor = isDark ? "#F87171" : primaryRed;

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg width="900" height="260" viewBox="0 0 900 260" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="badgeGrad" x1="0" y1="0" x2="200" y2="200" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#EF4444"/>
      <stop offset="100%" stop-color="#B91C1C"/>
    </linearGradient>
    <filter id="shadow" x="10" y="15" width="220" height="220" filterUnits="userSpaceOnUse">
      <feDropShadow dx="0" dy="8" stdDeviation="14" flood-color="#DC2626" flood-opacity="0.25"/>
    </filter>
  </defs>

  <!-- Left Emblem (200x200 at 30, 30) -->
  <g transform="translate(30, 30)">
    <rect width="200" height="200" rx="48" fill="url(#badgeGrad)" filter="url(#shadow)"/>
    
    <!-- Stylized W Inside Badge -->
    <g transform="translate(20, 20) scale(0.3125)">
      <!-- Left Wing -->
      <path d="M 112 168 C 112 150 128 138 144 146 L 206 342 C 212 360 198 376 180 376 C 168 376 158 368 152 356 L 98 186 C 94 176 98 168 112 168 Z" fill="white"/>
      
      <!-- Center Spanner / Wrench V-Crest -->
      <path d="M 186 362 L 232 236 C 235 228 244 222 254 222 C 255 222 257 222 258 222 C 268 222 277 228 280 236 L 326 362 C 332 378 318 392 302 392 C 290 392 280 384 276 372 L 256 312 L 236 372 C 232 384 222 392 210 392 C 194 392 180 378 186 362 Z" fill="white"/>
      
      <!-- Wrench Notch -->
      <path d="M 238 180 C 238 170 246 162 256 162 C 266 162 274 170 274 180 L 274 206 C 268 202 262 200 256 200 C 250 200 244 202 238 206 Z" fill="white"/>
      <circle cx="256" cy="180" r="16" fill="#B91C1C"/>
      
      <!-- Right Wing -->
      <path d="M 306 342 L 396 142 C 402 128 418 122 430 130 C 442 138 444 154 438 168 L 332 364 C 326 376 314 382 302 380 C 292 378 286 368 290 358 L 306 342 Z" fill="white"/>
      <circle cx="432" cy="132" r="14" fill="#FEF08A"/>
    </g>
  </g>

  <!-- Typography / Wordmark -->
  <text x="260" y="145" font-family="-apple-system, BlinkMacSystemFont, 'Plus Jakarta Sans', 'Segoe UI', Roboto, sans-serif" font-size="115" font-weight="800" letter-spacing="-2" fill="${weTextColor}">We<tspan fill="${fixTextColor}">Fix</tspan></text>
  
  <!-- Dot / Accent on Fix -->
  <circle cx="560" cy="82" r="9" fill="${dotColor}"/>
  
  <!-- Tagline -->
  <text x="264" y="195" font-family="-apple-system, BlinkMacSystemFont, 'Plus Jakarta Sans', 'Segoe UI', Roboto, sans-serif" font-size="22" font-weight="700" letter-spacing="4.5" fill="${tagColor}">VEHICLE SERVICE PLATFORM</text>
</svg>`;
}

// Write SVGs to assets/branding
fs.writeFileSync(path.join(brandingDir, 'wefix_symbol.svg'), getSymbolSvg(false, false), 'utf8');
fs.writeFileSync(path.join(brandingDir, 'wefix_app_icon.svg'), getSymbolSvg(true, false), 'utf8');
fs.writeFileSync(path.join(brandingDir, 'wefix_logo.svg'), getFullLogoSvg('light'), 'utf8');
fs.writeFileSync(path.join(brandingDir, 'wefix_logo_red.svg'), getFullLogoSvg('light'), 'utf8');
fs.writeFileSync(path.join(brandingDir, 'wefix_logo_white.svg'), getFullLogoSvg('dark'), 'utf8');

console.log("SVGs generated successfully!");

// Now render PNGs using headless Chrome
const tempHtmlPath = path.join(__dirname, 'temp_render.html');

function renderSvgToPng(svgContent, outPngPath, width, height, isOpaqueWhite = false) {
  const bgStyle = isOpaqueWhite ? "background: #FFFFFF;" : "background: transparent;";
  const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: ${width}px; height: ${height}px; overflow: hidden; ${bgStyle} }
    svg { width: 100%; height: 100%; display: block; }
  </style>
</head>
<body>
  ${svgContent}
</body>
</html>`;

  fs.writeFileSync(tempHtmlPath, html, 'utf8');
  const fileUrl = 'file:///' + tempHtmlPath.replace(/\\/g, '/');
  
  const cmd = `"${CHROME_PATH}" --headless --disable-gpu --force-device-scale-factor=1 --window-size=${width},${height} --default-background-color=00000000 --screenshot="${outPngPath}" "${fileUrl}"`;
  execSync(cmd, { stdio: 'pipe' });
}

try {
  console.log("Rendering branding PNGs...");
  renderSvgToPng(getFullLogoSvg('light'), path.join(brandingDir, 'wefix_logo_red.png'), 900, 260);
  renderSvgToPng(getFullLogoSvg('dark'), path.join(brandingDir, 'wefix_logo_white.png'), 900, 260);
  renderSvgToPng(getSymbolSvg(false, false), path.join(brandingDir, 'wefix_symbol.png'), 512, 512);
  renderSvgToPng(getSymbolSvg(true, false), path.join(brandingDir, 'wefix_app_icon.png'), 512, 512);
  
  console.log("Rendering Web icons & favicon...");
  renderSvgToPng(getSymbolSvg(true, false), path.join(webDir, 'favicon.png'), 64, 64);
  renderSvgToPng(getSymbolSvg(true, false), path.join(webIconsDir, 'Icon-192.png'), 192, 192);
  renderSvgToPng(getSymbolSvg(true, false), path.join(webIconsDir, 'Icon-512.png'), 512, 512);
  renderSvgToPng(getSymbolSvg(true, false), path.join(webIconsDir, 'Icon-maskable-192.png'), 192, 192);
  renderSvgToPng(getSymbolSvg(true, false), path.join(webIconsDir, 'Icon-maskable-512.png'), 512, 512);

  console.log("Rendering Android launcher icons...");
  const androidSizes = [
    { dir: 'mipmap-mdpi', size: 48 },
    { dir: 'mipmap-hdpi', size: 72 },
    { dir: 'mipmap-xhdpi', size: 96 },
    { dir: 'mipmap-xxhdpi', size: 144 },
    { dir: 'mipmap-xxxhdpi', size: 192 },
  ];

  androidSizes.forEach(({ dir, size }) => {
    const targetDir = path.join(resDir, dir);
    if (!fs.existsSync(targetDir)) fs.mkdirSync(targetDir, { recursive: true });
    renderSvgToPng(getSymbolSvg(true, false), path.join(targetDir, 'ic_launcher.png'), size, size);
  });

  if (fs.existsSync(tempHtmlPath)) fs.unlinkSync(tempHtmlPath);
  console.log("All brand assets, favicons, and launcher icons rendered successfully!");
} catch (e) {
  console.error("Rendering failed:", e);
}
