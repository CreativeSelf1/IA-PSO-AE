// Parámetros del Algoritmo Evolutivo
int tamañoPoblacion = 100; // [cite: 57, 58]
int dimensiones = 2; // 
float minX = -3.0; // 
float maxX = 7.0;  // 
float probMutacion = 0.6; // [cite: 61]
float probCruzamiento = 0.8; // [cite: 60]

Individuo[] poblacion;
Individuo mejorGlobal;

void setup() {
  size(800, 400);
  poblacion = new Individuo[tamañoPoblacion];
  
  // 1. Inicialización [cite: 54, 58]
  for (int i = 0; i < tamañoPoblacion; i++) {
    poblacion[i] = new Individuo();
  }
  mejorGlobal = poblacion[0];
  frameRate(60); // Para visualizar el progreso
}

void draw() {
  background(255);
  
  // 2. Evaluación [cite: 54, 58]
  for (Individuo ind : poblacion) {
    ind.evaluar();
    if (ind.fitness < mejorGlobal.fitness) {
      mejorGlobal = ind.copiar();
    }
  }

  // Visualización básica
  dibujarEstado();

  // 3. Selección (Torneo), 4. Cruzamiento y 5. Mutación [cite: 55, 59, 60, 61]
  Individuo[] nuevaPoblacion = new Individuo[tamañoPoblacion];
  for (int i = 0; i < tamañoPoblacion; i++) {
    // Selección por Torneo [cite: 59]
    Individuo padre1 = seleccionTorneo();
    Individuo padre2 = seleccionTorneo();
    
    // Cruzamiento [cite: 60]
    Individuo hijo = (random(1) < probCruzamiento) ? cruzamiento(padre1, padre2) : padre1.copiar();
    
    // Mutación [cite: 61]
    hijo.mutar();
    
    nuevaPoblacion[i] = hijo;
  }
  
  // 6. Reinserción (Generacional) [cite: 61]
  poblacion = nuevaPoblacion;
  
  fill(0);
  text("Mejor Fitness (Rastrigin): " + mejorGlobal.fitness, 10, 20);
}

// --- Clase Individuo ---
class Individuo {
  float[] genes = new float[dimensiones];
  float fitness;

  Individuo() {
    for (int i = 0; i < dimensiones; i++) {
      genes[i] = random(minX, maxX); // Inicialización aleatoria [cite: 58]
    }
  }

  void evaluar() {
    // Función Rastrigin 
    float n = dimensiones;
    float suma = 0;
    for (int i = 0; i < dimensiones; i++) {
      suma += pow(genes[i], 2) - 10 * cos(TWO_PI * genes[i]);
    }
    this.fitness = 10 * n + suma;
  }

  void mutar() {
    for (int i = 0; i < dimensiones; i++) {
      if (random(1) < probMutacion) {
        genes[i] += randomGaussian() * 0.5; // Mutación pequeña [cite: 61]
        genes[i] = constrain(genes[i], minX, maxX); // Mantener en dominio 
      }
    }
  }

  Individuo copiar() {
    Individuo copia = new Individuo();
    for (int i = 0; i < dimensiones; i++) copia.genes[i] = this.genes[i];
    copia.fitness = this.fitness;
    return copia;
  }
}

// --- Operadores ---
Individuo seleccionTorneo() {
  // Elige 3 al azar y devuelve el mejor [cite: 59]
  Individuo mejor = poblacion[(int)random(tamañoPoblacion)];
  for (int i = 0; i < 2; i++) {
    Individuo candidato = poblacion[(int)random(tamañoPoblacion)];
    if (candidato.fitness < mejor.fitness) mejor = candidato;
  }
  return mejor;
}

Individuo cruzamiento(Individuo p1, Individuo p2) {
  Individuo hijo = new Individuo();
  int puntoCorte = (int)random(dimensiones); // Cruzamiento de un punto [cite: 60]
  for (int i = 0; i < dimensiones; i++) {
    hijo.genes[i] = (i <= puntoCorte) ? p1.genes[i] : p2.genes[i];
  }
  return hijo;
}

void dibujarEstado() {
  // Mapeo simple para ver los individuos en el plano 2D
  for (Individuo ind : poblacion) {
    float x = map(ind.genes[0], minX, maxX, 50, width-50);
    float y = map(ind.genes[1], minX, maxX, 50, height-50);
    fill(0, 150, 255, 100);
    ellipse(x, y, 10, 10);
  }
}
