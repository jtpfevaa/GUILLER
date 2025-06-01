#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const { execSync } = require('child_process');

// Función que construye imagen marco si falta original
//
function construirMarco({ targetPath, name, alias, font, fontSize }) {
  const OUTPUT = targetPath;
  const TEXT = alias ? `${name}: ${alias}` : name;
  const TMP_ID = Date.now(); // Para evitar colisiones en tmp

  const TEMP_INPUT = `/tmp/empty-${TMP_ID}.png`;
  const WIDTH = 400, HEIGHT = 400;
  const MARGIN = 15, HEADER = 15;

  // Crear un PNG vacío como contenido de relleno
  execSync(`convert -size ${WIDTH}x${HEIGHT} xc:black "${TEMP_INPUT}"`);

  const NEW_WIDTH = WIDTH + 2 * MARGIN;
  const NEW_HEIGHT = HEIGHT + 2 * MARGIN + HEADER;

  // Construir comando final
  const cmd = [
    `convert -size ${NEW_WIDTH}x${NEW_HEIGHT} xc:white`,
    font ? `-font "${font}"` : '',
    `-pointsize ${fontSize || 32}`,
    `-fill black`,
    `-draw "text ${MARGIN},${HEADER + 10} '${TEXT}'"`,
    `"${TEMP_INPUT}" -geometry +${MARGIN}+${HEADER+MARGIN} -composite`,
    `"${OUTPUT}"`
  ].join(' ');

  try {
    execSync(cmd);
    console.log(`📸 Marco creado en: ${OUTPUT}`);
    console.log(`📸 Comando: ${cmd}`);
  } catch (err) {
    console.error(`❌ Error al construir marco: ${err.message}`);
  } finally {
    fs.unlinkSync(TEMP_INPUT); // Limpieza del temporal
  }
}

// Función para parsear argumentos estilo --key value o --flag
function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const arg = argv[i];
    if (arg.startsWith('--')) {
      const key = arg.slice(2);
      const next = argv[i + 1];
      if (next && !next.startsWith('--')) {
        args[key] = next;
        i++;
      } else {
        args[key] = true; // Flag booleano
      }
    }
  }
  return args;
}

const args = parseArgs(process.argv);

// Mostrar ayuda si se usa --help
if (args.help) {
  console.log(`
🟢 USO:
  node checkStars.js [--input archivo.js] [--origin directorio_origen] [--target directorio_destino] [--copy] [--dry-run]

📄 PARÁMETROS:

  --input   Fichero JS que define la variable global 'starsInx'.
            Por defecto: stars.js

  --origin  Directorio base donde están las carpetas de las constelaciones.
            Cada carpeta debe tener su subcarpeta 'photos/' con las imágenes.
            Por defecto: ./photos

  --target  Directorio donde se crearán los hard links o copias.
            Por defecto: /usr/share/stellarium/textures/img/photos

  --copy    En lugar de hard links, copiar los archivos.

  --dry-run Modo simulación. Muestra lo que se haría sin modificar nada.

  --help    Muestra esta ayuda y sale.

🧪 EJEMPLOS:

  node checkStars.js
  node checkStars.js --input stars.js --dry-run
  node checkStars.js --input stars.js --copy
  node checkStars.js --input config.js --origin ./imgs --target ./dest --copy
`);
  process.exit(0);
}

// Parámetros con valores por defecto
const inputFile = args.input || 'stars.js';
const originRoot = args.origin || path.join(__dirname, 'photos');
const targetRoot = args.target || '/usr/share/stellarium/textures/img/photos';
const dryRun = !!args['dry-run'];
const copyInsteadOfLink = !!args.copy;

// Asegurar que targetRoot existe y está limpio
if (fs.existsSync(targetRoot)) {
  console.log(`🧹 Habría que limpiar contenido de ${targetRoot}...`);
  console.log(`📁 Se sobreescribe sobre ese directorio: ${targetRoot}`);
}

console.log(`🔧 Configuración:
  📄 Archivo JS:             ${inputFile}
  📂 Directorio origen:      ${originRoot}
  🎯 Directorio destino:     ${targetRoot}
  🚧 Modo simulación:        ${dryRun ? 'Sí' : 'No'}
  🔄 Operación:              ${copyInsteadOfLink ? 'Copiar' : 'Hard Link'}
`);

// Cargar archivo JS
const starsModulePath = path.resolve(inputFile);
if (!fs.existsSync(starsModulePath)) {
  console.error(`❌ El archivo "${starsModulePath}" no existe.`);
  process.exit(1);
}

const { starsInx } = require(starsModulePath);

if (typeof starsInx === 'undefined') {
  console.error('❌ El archivo JS no define "starsInx" como variable global.');
  process.exit(1);
}

let total = 0;
let found = 0;
let missing = 0;

// Función para crear hard link o copiar
function procesarImagen({ imgPath, constellation, star }) {

    const fileName = `${star.img}.png`;
    const targetPath = path.join(targetRoot, fileName);

  if (fs.existsSync(targetPath)) {
    console.log(`ℹ️ Ya existe: ${targetPath}`);
    return;
  }

  if (dryRun) {
    console.log(`🟡 [SIMULACIÓN] ${copyInsteadOfLink ? 'Copiaría' : 'Crearía link'} → ${targetPath}`);
    return;
  }

  try {
    if (copyInsteadOfLink) {
      fs.copyFileSync(imgPath, targetPath);
      console.log(`📋 Copiado: ${targetPath}`);
    } else {
      fs.linkSync(imgPath, targetPath);
      console.log(`🔗 Link creado: ${targetPath}`);
    }
  } catch (err) {
    console.error(`❌ Error con ${imgPath}: ${err.message}`);
  }
}

// Recorrer constelaciones
starsInx.forEach(({ constname, stars }) => {
  const photosDir = path.join(originRoot, constname, 'photos');

  stars.forEach(star => {
    total++;
    const imgFile = `${star.img}.png`;
    const imgPath = path.join(photosDir, imgFile);
    const fileName = `${star.img}.png`;
    const targetPath = path.join(targetRoot, fileName);

    if (fs.existsSync(imgPath)) {
      found++;
    } else {
      missing++;
      console.warn(`⚠️ Imagen no encontrada: ${imgPath}`);
      construirMarco({targetPath,name: star.name, alias: star.alias, font: "DejaVu-Sans",fontSize: 20});
    }
    procesarImagen({ imgPath, constellation: constname, star });
  });
});

console.log(`\n📊 Resumen:
  Total de imágenes procesadas: ${total}
  Encontradas: ${found}
  No encontradas: ${missing}
`);
