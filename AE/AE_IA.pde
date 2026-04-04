// ===============================================================
// EA - Optimización de Función Rastrigin 2D
// INFO257 - Inteligencia Artificial
// ===============================================================

// Selección de modo desde config_ea.json (0: Exploración, 1: Explotación, 2: Balanceada)
int MODO_A_EJECUTAR = 2;

// Dominio de la función
float xMin = -3;
float xMax = 7;

// Parámetros EA (cargados desde config_ea.json)
int popSize;
int kTorneo;
float pCrossover;
float alphaBLX;
float pMutacion;
float sigma;
int elitismo;

String runName, rutaSalida;

// Control de múltiples ejecuciones
int totalRuns = 30;
int currentRun = 1;
boolean runDone = false;
int seedActual;

// Estado EA
Individual[] poblacion;
Individual[] nuevaPoblacion;

float gbestx, gbesty, gbest;
int gen = 0;
int maxGen = 150;

float[] bestHist, avgHist;

// Visual
PImage surf;
float d = 8;

// ===============================================================
void setup() {
  size(600, 600);
  cargarConfiguracion(MODO_A_EJECUTAR);

  surf = loadImage("mapa_calor.png");

  iniciarNuevaEjecucion();
}

// ===============================================================
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

  background(40);
  if (surf != null) image(surf, 0, 0, width, height);

  // Dibujar población actual
  for (int i = 0; i < popSize; i++) {
    poblacion[i].display();
  }

  // Guardar historial
  bestHist[gen] = gbest;
  avgHist[gen] = calcAverageFitness(poblacion);

  despliegaInfo();

  // Ejecutar 1 generación
  evolucionar();

  gen++;

  if (gen >= maxGen) {
    saveResultsCSV();
    runDone = true;
  }
}

// ===============================================================
// INICIALIZACIÓN DE CADA EJECUCIÓN
// ===============================================================
void iniciarNuevaEjecucion() {
  seedActual = int(random(1000000));
  randomSeed(seedActual);

  gen = 0;
  runDone = false;

  bestHist = new float[maxGen];
  avgHist  = new float[maxGen];

  poblacion = new Individual[popSize];
  nuevaPoblacion = new Individual[popSize];

  // Crear población aleatoria
  for (int i = 0; i < popSize; i++) {
    poblacion[i] = new Individual();
    poblacion[i].eval();
  }

  // Inicializar mejor global
  actualizarBestGlobal();

  println("Ejecución " + currentRun + "/" + totalRuns +
          " | Modo: " + runName.toUpperCase() +
          " | Seed: " + seedActual);
}

// ===============================================================
// CLASE INDIVIDUO
// ===============================================================
class Individual {
  float x, y;
  float fit;

  Individual() {
    x = random(xMin, xMax);
    y = random(xMin, xMax);
    fit = Float.MAX_VALUE;
  }

  Individual(float xx, float yy) {
    x = xx;
    y = yy;
    fit = Float.MAX_VALUE;
  }

  float eval() {
    float term1 = x * x - 10 * cos(TWO_PI * x);
    float term2 = y * y - 10 * cos(TWO_PI * y);
    fit = 20 + term1 + term2;
    return fit;
  }

  Individual copy() {
    Individual c = new Individual(x, y);
    c.fit = fit;
    return c;
  }

  void mutate() {
    if (random(1) < pMutacion) {
      x += randomGaussian() * sigma;
      y += randomGaussian() * sigma;

      x = constrain(x, xMin, xMax);
      y = constrain(y, xMin, xMax);
    }
  }

  void display() {
    float rX = map(x, xMin, xMax, 0, width);
    float rY = map(y, xMin, xMax, height, 0);
    noStroke();
    fill(0, 200, 255, 200);
    ellipse(rX, rY, d, d);
  }
}

// ===============================================================
// OPERADORES EA
// ===============================================================

// Selección k-torneo (minimización)
Individual torneo() {
  Individual best = null;

  for (int i = 0; i < kTorneo; i++) {
    int idx = int(random(popSize));
    Individual candidato = poblacion[idx];

    if (best == null || candidato.fit < best.fit) {
      best = candidato;
    }
  }
  return best;
}

// Cruzamiento BLX-alpha
Individual cruzamientoBLX(Individual p1, Individual p2) {

  float cx, cy;

  float minX = min(p1.x, p2.x);
  float maxX = max(p1.x, p2.x);
  float Ix = maxX - minX;

  float minY = min(p1.y, p2.y);
  float maxY = max(p1.y, p2.y);
  float Iy = maxY - minY;

  cx = random(minX - alphaBLX * Ix, maxX + alphaBLX * Ix);
  cy = random(minY - alphaBLX * Iy, maxY + alphaBLX * Iy);

  cx = constrain(cx, xMin, xMax);
  cy = constrain(cy, xMin, xMax);

  return new Individual(cx, cy);
}

// Evolución generacional
void evolucionar() {

  // 1) Ordenar población para elitismo
  Individual[] ordenados = ordenarPorFitness(poblacion);

  int idx = 0;

  // 2) Copiar élite
  for (int e = 0; e < elitismo; e++) {
    nuevaPoblacion[idx] = ordenados[e].copy();
    idx++;
  }

  // 3) Generar el resto con selección + crossover + mutación
  while (idx < popSize) {

    Individual padre1 = torneo();
    Individual padre2 = torneo();

    Individual hijo;

    if (random(1) < pCrossover) {
      hijo = cruzamientoBLX(padre1, padre2);
    } else {
      hijo = padre1.copy();
    }

    hijo.mutate();
    hijo.eval();

    nuevaPoblacion[idx] = hijo;
    idx++;
  }

  // 4) Reemplazo generacional
  for (int i = 0; i < popSize; i++) {
    poblacion[i] = nuevaPoblacion[i];
  }

  // 5) Actualizar best global
  actualizarBestGlobal();
}

// ===============================================================
// UTILIDADES
// ===============================================================

// Actualizar mejor global
void actualizarBestGlobal() {
  gbest = Float.MAX_VALUE;

  for (int i = 0; i < popSize; i++) {
    if (poblacion[i].fit < gbest) {
      gbest = poblacion[i].fit;
      gbestx = poblacion[i].x;
      gbesty = poblacion[i].y;
    }
  }
}

// Fitness promedio
float calcAverageFitness(Individual[] pop) {
  float sum = 0;
  for (int i = 0; i < popSize; i++) sum += pop[i].fit;
  return sum / popSize;
}

// Ordenar por fitness ascendente
Individual[] ordenarPorFitness(Individual[] pop) {
  Individual[] copia = new Individual[popSize];
  for (int i = 0; i < popSize; i++) copia[i] = pop[i].copy();

  for (int i = 0; i < popSize; i++) {
    for (int j = i + 1; j < popSize; j++) {
      if (copia[j].fit < copia[i].fit) {
        Individual tmp = copia[i];
        copia[i] = copia[j];
        copia[j] = tmp;
      }
    }
  }
  return copia;
}

// Panel info
void despliegaInfo() {
  fill(0, 190);
  noStroke();
  rect(5, 5, 320, 130);

  fill(0, 220, 0);
  textSize(12);

  text("EJECUCIÓN: " + currentRun + " / " + totalRuns, 15, 24);
  text("MODO:      " + runName.toUpperCase(), 15, 40);

  text("pop=" + popSize + " k=" + kTorneo +
       " elit=" + elitismo, 15, 56);

  text("pCross=" + nf(pCrossover, 0, 2) +
       " alpha=" + nf(alphaBLX, 0, 2), 15, 72);

  text("pMut=" + nf(pMutacion, 0, 2) +
       " sigma=" + nf(sigma, 0, 2), 15, 88);

  text("Best fitness: " + nf(gbest, 0, 6), 15, 104);
  text("Generación: " + gen + " / " + maxGen, 15, 120);

  // Marca mejor global en rojo
  float bX = map(gbestx, xMin, xMax, 0, width);
  float bY = map(gbesty, xMin, xMax, height, 0);

  stroke(255, 0, 0);
  noFill();
  strokeWeight(2);
  ellipse(bX, bY, 18, 18);
  strokeWeight(1);
}

// ===============================================================
// EXPORTAR CSV
// ===============================================================
void saveResultsCSV() {
  String filename = rutaSalida + "ea_" + runName + "_run_" + nf(currentRun, 2) + ".csv";

  String[] lines = new String[maxGen + 1];
  lines[0] = "iter,best,average";

  for (int i = 0; i < maxGen; i++) {
    lines[i + 1] = i + "," + bestHist[i] + "," + avgHist[i];
  }

  saveStrings(filename, lines);
  println("  -> Guardado: " + filename + " | gbest final = " + nf(gbest, 0, 6));
}

// ===============================================================
// CARGAR CONFIGURACIÓN DESDE JSON
// ===============================================================
void cargarConfiguracion(int indice) {
  JSONObject json = loadJSONObject("config_ea.json");
  JSONArray configs = json.getJSONArray("configuraciones");

  if (indice < 0 || indice >= configs.size()) {
    println("ERROR: índice inválido (" + indice + ")");
    exit();
  }

  JSONObject c = configs.getJSONObject(indice);

  runName = c.getString("nombre");
  popSize = c.getInt("popSize");
  kTorneo = c.getInt("kTorneo");
  pCrossover = c.getFloat("pCrossover");
  alphaBLX = c.getFloat("alphaBLX");
  pMutacion = c.getFloat("pMutacion");
  sigma = c.getFloat("sigma");
  elitismo = c.getInt("elitismo");
  rutaSalida = c.getString("ruta_salida");

  // Crear carpeta si no existe
  File f = new File(sketchPath(rutaSalida));
  if (!f.exists()) f.mkdirs();

  println("Configuración cargada: " + runName);
  println("  pop=" + popSize +
          " k=" + kTorneo +
          " pCross=" + pCrossover +
          " alpha=" + alphaBLX +
          " pMut=" + pMutacion +
          " sigma=" + sigma +
          " elit=" + elitismo);
}
