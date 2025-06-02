#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const args = parseArgs(process.argv);
// Parámetros con valores por defecto
const inputFile = args.input || 'stars.js';
const originRoot = args.origin || path.join(__dirname, 'ori');
const targetRoot = args.target || '/usr/share/stellarium/textures/img/photos';
const dryRun = !!args['dry-run'];
const copyInsteadOfLink = !!args.copy;

const FONT = "DejaVu-Sans";
const FONTSIZE = 20;

// Crear un PNG vacío como contenido de relleno
const HEIGHT = 400;
const WIDTH = 400;
const TMP_ID = Date.now();
const TEMP_INPUT = `/tmp/empty-${TMP_ID}.png`;

execSync(`convert -size ${WIDTH}x${HEIGHT} xc:black "${TEMP_INPUT}"`);

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

// Función para obtener dimensiones imagen con ImageMagick identify
function getImageDimensions(filePath) {
  try {
    const output = execSync(`identify -format "%w %h" "${filePath}"`).toString();
    const [width, height] = output.trim().split(' ').map(Number);
    return { width, height };
  } catch (err) {
    console.warn(`⚠️ No se pudieron obtener dimensiones de ${filePath}, usando 400x400 por defecto.`);
    return { width: 400, height: 400 };
  }
}

// Función que construye imagen marco si falta original
//
function construirMarcoImage({ originPath, outputPath, title, font, fontSize }) {
  const { width, height } = getImageDimensions(originPath);

  const MARGIN = 15, HEADER = 15;
  const NEW_WIDTH = width + 2 * MARGIN;
  const NEW_HEIGHT = height + 2 * MARGIN + HEADER;

  console.log(`ORIGINPATH: ${originPath}`);
  console.log(`OUTPUTPATH: ${outputPath}`);
  // Construir comando final
  const cmd = [
    `convert -size ${NEW_WIDTH}x${NEW_HEIGHT} xc:white`,
    font ? `-font "${font}"` : '',
    `-pointsize ${fontSize || 32}`,
    `-fill black`,
    `-draw "text ${MARGIN},${HEADER + 10} '${title}'"`,
    `"${originPath}" -geometry +${MARGIN}+${HEADER+MARGIN} -composite`,
    `"${outputPath}"`
  ].join(' ');
  if (dryRun) {
    console.log(`[SIMULACIÓN] Comando para marco imagen: ${cmd}`);
    return;
  }

  try {
    execSync(cmd);
    console.log(`📸 Marco creado en: ${outputPath}`);
    console.log(`📸 Comando: ${cmd}`);
  } catch (err) {
    console.error(`❌ Error al construir marco: ${err.message}`);
  }
}

// Mostrar ayuda si se usa --help
if (args.help) {
  console.log(`
🟢 USO:
  node checkStars.js [--input archivo.js] [--origin directorio_origen] [--target directorio_destino] [--copy] [--dry-run]

📄 PARÁMETROS:

  --input   Fichero JS que define la variable global 'starsInx'.
            Por defecto: stars.js

  --origin  Directorio base donde están las carpetas de las constelaciones.
            Cada carpeta debe tener su subcarpeta 'ori/' con las imágenes iniciales y 'photos/' con las imágenes construidas.

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

// Recorrer constelaciones
starsInx.forEach(({ constname, stars }) => {
  const oriDir = path.join(originRoot, constname, 'ori');
  const photosDir = path.join(originRoot, constname, 'photos');

  stars.forEach(star => {
    total++;
    const imgFile = `${star.img}.png`;
    const oriPath = path.join(oriDir, imgFile);
    const photosPath = path.join(photosDir, imgFile);
    const fileName = `${star.img}.png`;
    const targetPath = path.join(targetRoot, fileName);
    const text= star.alias ? `${star.name}: ${star.alias}` : star.name;

    console.log(`fileName: ${fileName}`);
    console.log(`oriPath: ${oriPath}`);

    if (fs.existsSync(oriPath)) {
      found++;
      construirMarcoImage({originPath: oriPath, outputPath: targetPath, title: text, font: "DejaVu-Sans", fontSize: 20 });
      if (!dryRun) {
        console.log(`[SIMULACIÓN] Copiando fichero photo: ${photosPath}`);
	if(fs.existsSync(photosPath)) {
		fs.unlinkSync(photosPath);
	}
        fs.linkSync(targetPath, photosPath);
      }
    } else {
      missing++;
      console.warn(`⚠️ Imagen no encontrada: ${oriPath}`);

      construirMarcoImage({ originPath: TEMP_INPUT, outputPath: targetPath, title: text, font: "DejaVu-Sans", fontSize: 20 }); 
    }
  });
});

fs.unlinkSync(TEMP_INPUT); // Limpieza del temporal

console.log(`\n📊 Resumen:
  Total de imágenes procesadas: ${total}
  Encontradas: ${found}
  No encontradas: ${missing}
`);
