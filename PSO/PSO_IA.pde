// ===============================================================
// PSO
// ===============================================================

// Modo de ejecuión
// Exploración 0
// Explotación 1

int MODO_A_EJECUTAR = 0; 

// Dominio
float xMin = -3;
float xMax = 7;

// Parámetros
float w, C1, C2, maxv;
int puntos, maxIter = 200;
String runName, rutaSalida;

//Control de Flujo
int currentRun = 1;      // 1: Fija, 2: Aleatoria
boolean finished = false;
int seedFija = 1234;
int seedActual;

// Variables PSO
Particle[] fl;
float gbestx, gbesty, gbest;
int evals, iter = 0;
float[] bestHist, avgHist;
PImage surf;
float d = 15;


// ===============================================================
// CLASE PARTICLE
// ===============================================================
class Particle {
  float x, y, fit, px, py, pfit, vx, vy;

  Particle() {
    x = random(xMin, xMax);
    y = random(xMin, xMax);
    vx = random(-1, 1);
    vy = random(-1, 1);
    fit = pfit = 1000000;
  }
  
  //Función Rastring
  float Eval() {
    evals++;
    float term1 = pow(x, 2) - 10 * cos(TWO_PI * x);
    float term2 = pow(y, 2) - 10 * cos(TWO_PI * y);
    fit = 20 + term1 + term2;

    if (fit < pfit) { pfit = fit; px = x; py = y; }
    if (fit < gbest) { gbest = fit; gbestx = x; gbesty = y; }
    return fit;
  }

  void move() {
    vx = w * vx + random(0,1) * C1 * (px - x) + random(0,1) * C2 * (gbestx - x);
    vy = w * vy + random(0,1) * C1 * (py - y) + random(0,1) * C2 * (gbesty - y);

    float modu = sqrt(vx * vx + vy * vy);
    if (modu > maxv) { vx = (vx / modu) * maxv; vy = (vy / modu) * maxv; }

    x += vx; y += vy;
    if (x > xMax || x < xMin) vx *= -0.5;
    if (y > xMax || y < xMin) vy *= -0.5;
    x = constrain(x, xMin, xMax);
    y = constrain(y, xMin, xMax);
  }

  void display() {
    float rX = map(x, xMin, xMax, 0, width);
    float rY = map(y, xMin, xMax, height, 0);
    fill(255, 180);
    ellipse(rX, rY, d-5, d-5);
  }
}


void draw() {
  if (finished) {
    if (currentRun == 1) {
      currentRun = 2;
      int nuevaSemilla = int(random(10000, 99999));
      println("\n--- INICIANDO MODO: " + runName.toUpperCase() + " (Semilla Aleatoria: " + nuevaSemilla + ") ---");
      resetRun(nuevaSemilla);
    } else {
      println("\n[PROCESO COMPLETADO PARA MODO: " + runName + "]");
      noLoop();
      return;
    }
  }

  background(50);
  if (surf != null) image(surf, 0, 0, width, height);

  for (int i = 0; i < puntos; i++) {
    fl[i].move();
    fl[i].Eval();
    fl[i].display();
  }

  despliegaInfo();
  bestHist[iter] = gbest;
  avgHist[iter] = calcAverageFitness();
  iter++;

  if (iter >= maxIter) {
    saveResultsCSV();
    finished = true;
  }
}



void resetRun(int s) {
  seedActual = s;
  randomSeed(s);
  iter = 0; evals = 0; gbest = 1000000; finished = false;
  bestHist = new float[maxIter];
  avgHist = new float[maxIter];
  fl = new Particle[puntos];
  for (int i = 0; i < puntos; i++) fl[i] = new Particle();
}


void saveResultsCSV() {
  // Ahora usa la rutaSalida definida en el JSON
  String tipoSeed = (currentRun == 1) ? "fija" : "aleat";
  String filename = rutaSalida + "pso_" + runName + "_" + tipoSeed + "_s" + seedActual + ".csv";
  
  String[] lines = new String[iter + 1];
  lines[0] = "iter,best,average";
  for (int i = 0; i < iter; i++) lines[i + 1] = i + "," + bestHist[i] + "," + avgHist[i];

  saveStrings(filename, lines);
  println("Archivo guardado en: " + filename);
}

float calcAverageFitness() {
  float sum = 0;
  for (int i = 0; i < puntos; i++) sum += fl[i].fit;
  return sum / puntos;
}


void despliegaInfo() {
  fill(0, 150);
  rect(5, 5, 250, 110);
  fill(0, 255, 0);
  text("MODO: " + runName.toUpperCase(), 15, 25);
  text("Parámetros: w=" + w + " C1=" + C1 + " C2=" + C2, 15, 40);
  text("Seed: " + seedActual, 15, 55);
  text("Best Fitness: " + nf(gbest, 0, 5), 15, 75);
  text("Iteración: " + iter + " / " + maxIter, 15, 90);
  
  float bX = map(gbestx, xMin, xMax, 0, width);
  float bY = map(gbesty, xMin, xMax, height, 0);
  stroke(0, 0, 255); noFill();
  ellipse(bX, bY, 20, 20);
}


//configuración y carga config.json parametros
void cargarConfiguracion(int indice) {
  JSONObject json = loadJSONObject("config.json");
  JSONArray configs = json.getJSONArray("configuraciones");
  
  if (indice >= configs.size()) {
    println("ERROR: El índice de modo no existe en el JSON.");
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
  
  // Crear la carpeta de salida si no existe
  File f = new File(sketchPath(rutaSalida));
  if (!f.exists()) f.mkdirs();
}


void setup() {
  size(600, 600);
  //Carga config
  cargarConfiguracion(MODO_A_EJECUTAR);
  
  surf = loadImage("mapa_calor.png"); 
  println("--- INICIANDO MODO: " + runName.toUpperCase() + " (Semilla Fija) ---");
  resetRun(seedFija);
}
