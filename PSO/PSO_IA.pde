// ===============================================================
// PSO - Optimización de Función Rastrigin 2D
// INFO257 - Inteligencia Artificial
// ===============================================================

// Selección de modo desde config.json (0: Exploración, 1: Explotación, 2: Balanceada)
int MODO_A_EJECUTAR = 2;

// Dominio de la función
float xMin = -3;
float xMax = 7;

// Parámetros PSO (cargados desde config.json)
float w, C1, C2, maxv;
int puntos;
int maxIter = 150;
String runName, rutaSalida;

// Control de múltiples ejecuciones
int totalRuns = 30;
int currentRun = 1;
boolean runDone = false;
int seedActual;

// Estado del PSO
Particle[] fl;
float gbestx, gbesty, gbest;
int iter = 0;
float[] bestHist, avgHist;
PImage surf;
float d = 8;

// ---------------------------------------------------------------
void setup() {
  size(600, 600);
  cargarConfiguracion(MODO_A_EJECUTAR);

  // Intenta cargar mapa de calor si existe (solo decorativo)
  surf = loadImage("mapa_calor.png");

  iniciarNuevaEjecucion();
}

// ---------------------------------------------------------------
void draw() {
  if (runDone) {
    if (currentRun < totalRuns) {
      currentRun++;
      iniciarNuevaEjecucion();
    } else {
      println("\n[COMPLETADO] " + totalRuns + " ejecuciones guardadas en: " + rutaSalida);
      noLoop();
      return;
    }
  }

  // Fondo y mapa decorativo
  background(40);
  if (surf != null) image(surf, 0, 0, width, height);

  // Un paso PSO: mover, evaluar, dibujar
  for (int i = 0; i < puntos; i++) {
    fl[i].move();
    fl[i].Eval();
    fl[i].display();
  }

  // Registro de convergencia
  bestHist[iter] = gbest;
  avgHist[iter]  = calcAverageFitness();

  despliegaInfo();
  iter++;

  if (iter >= maxIter) {
    saveResultsCSV();
    runDone = true;
  }
}

// ---------------------------------------------------------------
// INICIALIZACIÓN DE CADA EJECUCIÓN
// ---------------------------------------------------------------
void iniciarNuevaEjecucion() {
  seedActual = int(random(1000000));
  randomSeed(seedActual);

  iter    = 0;
  gbest   = Float.MAX_VALUE;   // Minimización: iniciar en +infinito
  gbestx  = 0;
  gbesty  = 0;
  runDone = false;

  bestHist = new float[maxIter];
  avgHist  = new float[maxIter];
  fl = new Particle[puntos];

  // 1) Crear partículas con posición y velocidad iniciales
  for (int i = 0; i < puntos; i++) {
    fl[i] = new Particle();
  }

  // 2) Evaluación inicial ANTES del primer movimiento
  //    Esto garantiza que px/py y gbest sean correctos desde la iter 0
  for (int i = 0; i < puntos; i++) {
    fl[i].Eval();
  }

  println("Ejecución " + currentRun + "/" + totalRuns +
          " | Modo: " + runName.toUpperCase() +
          " | Seed: " + seedActual);
}

// ---------------------------------------------------------------
// CLASE PARTÍCULA
// ---------------------------------------------------------------
class Particle {
  float x, y, fit;        // posición actual y fitness actual
  float px, py, pfit;     // mejor posición personal y su fitness
  float vx, vy;           // velocidad

  Particle() {
    x  = random(xMin, xMax);
    y  = random(xMin, xMax);

    // Velocidad inicial escalada a maxv para ser coherente con los límites
    vx = random(-maxv * 0.5, maxv * 0.5);
    vy = random(-maxv * 0.5, maxv * 0.5);

    // FIX CRÍTICO: inicializar personal best en la posición inicial
    px   = x;
    py   = y;
    pfit = Float.MAX_VALUE;   // Se actualizará en la primera Eval()
    fit  = Float.MAX_VALUE;
  }

  // Función Rastrigin 2D: f(x,y) = 20 + x²-10cos(2πx) + y²-10cos(2πy)
  float Eval() {
    float term1 = x * x - 10 * cos(TWO_PI * x);
    float term2 = y * y - 10 * cos(TWO_PI * y);
    fit = 20 + term1 + term2;

    // Actualizar mejor personal
    if (fit < pfit) {
      pfit = fit;
      px   = x;
      py   = y;
    }

    // Actualizar mejor global
    if (fit < gbest) {
      gbest  = fit;
      gbestx = x;
      gbesty = y;
    }
    return fit;
  }

  // Actualización de velocidad y posición (fórmula estándar con inercia)
  void move() {
    float r1 = random(0, 1);
    float r2 = random(0, 1);

    vx = w * vx + r1 * C1 * (px - x) + r2 * C2 * (gbestx - x);
    vy = w * vy + r1 * C1 * (py - y) + r2 * C2 * (gbesty - y);

    // Limitar velocidad máxima (módulo del vector)
    float modu = sqrt(vx * vx + vy * vy);
    if (modu > maxv) {
      vx = (vx / modu) * maxv;
      vy = (vy / modu) * maxv;
    }

    x += vx;
    y += vy;

    // Reflexión en los bordes: invierte y amortigua la componente que salió
    if (x > xMax || x < xMin) { vx *= -0.5; }
    if (y > xMax || y < xMin) { vy *= -0.5; }

    x = constrain(x, xMin, xMax);
    y = constrain(y, xMin, xMax);
  }

  void display() {
    float rX = map(x, xMin, xMax, 0, width);
    float rY = map(y, xMin, xMax, height, 0);
    noStroke();
    fill(255, 180, 0, 200);
    ellipse(rX, rY, d, d);
  }
}

// ---------------------------------------------------------------
// GUARDAR CSV CON RESULTADOS DE LA EJECUCIÓN
// ---------------------------------------------------------------
void saveResultsCSV() {
  String filename = rutaSalida + "pso_" + runName + "_run_" + nf(currentRun, 2) + ".csv";
  String[] lines = new String[maxIter + 1];
  lines[0] = "iter,best,average";
  for (int i = 0; i < maxIter; i++) {
    lines[i + 1] = i + "," + bestHist[i] + "," + avgHist[i];
  }
  saveStrings(filename, lines);
  println("  -> Guardado: " + filename + " | gbest final = " + nf(gbest, 0, 6));
}

// ---------------------------------------------------------------
// UTILIDADES
// ---------------------------------------------------------------
float calcAverageFitness() {
  float sum = 0;
  for (int i = 0; i < puntos; i++) sum += fl[i].fit;
  return sum / puntos;
}

void despliegaInfo() {
  // Panel de información en pantalla
  fill(0, 190);
  noStroke();
  rect(5, 5, 280, 120);

  fill(0, 220, 0);
  textSize(12);
  text("EJECUCIÓN: " + currentRun + " / " + totalRuns,           15, 24);
  text("MODO:      " + runName.toUpperCase(),                      15, 40);
  text("w=" + nf(w,0,3) + "  C1=" + nf(C1,0,2) + "  C2=" + nf(C2,0,2), 15, 56);
  text("maxv=" + nf(maxv,0,2) + "  partículas=" + puntos,         15, 72);
  text("Best fitness: " + nf(gbest, 0, 6),                         15, 88);
  text("Iteración: " + iter + " / " + maxIter,                    15, 104);

  // Marca la mejor posición global en rojo
  float bX = map(gbestx, xMin, xMax, 0, width);
  float bY = map(gbesty, xMin, xMax, height, 0);
  stroke(255, 0, 0);
  noFill();
  strokeWeight(2);
  ellipse(bX, bY, 18, 18);
  strokeWeight(1);
}

// ---------------------------------------------------------------
// CARGA DE CONFIGURACIÓN DESDE JSON
// ---------------------------------------------------------------
void cargarConfiguracion(int indice) {
  JSONObject json = loadJSONObject("config.json");
  JSONArray configs = json.getJSONArray("configuraciones");

  if (indice < 0 || indice >= configs.size()) {
    println("ERROR: índice de configuración inválido (" + indice + ")");
    exit();
  }

  JSONObject c = configs.getJSONObject(indice);
  runName    = c.getString("nombre");
  w          = c.getFloat("w");
  C1         = c.getFloat("c1");
  C2         = c.getFloat("c2");
  maxv       = c.getFloat("maxv");
  puntos     = c.getInt("puntos");
  rutaSalida = c.getString("ruta_salida");

  // Crear directorio de salida si no existe
  File f = new File(sketchPath(rutaSalida));
  if (!f.exists()) f.mkdirs();

  println("Configuración cargada: " + runName);
  println("  w=" + w + " C1=" + C1 + " C2=" + C2 + " maxv=" + maxv + " puntos=" + puntos);
}
