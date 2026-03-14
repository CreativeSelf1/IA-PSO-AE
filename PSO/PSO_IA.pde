// PSO adaptado para la tarea de IA PSO
// Objetivo: Minimizar la función Rastrigin en dominio [-3, 7] 

// PImage surf; // Ya no usamos imagen para el fitness

// ===============================================================
int puntos = 100;
PImage surf;
Particle[] fl; // arreglo de partículas
float d = 15; // radio del círculo, solo para despliegue
float gbestx, gbesty, gbest; // posición y fitness del mejor global
float w = 1000; // inercia:    baja -> explotación,   alta -> exploración
float C1 = 2, C2 = 1; // learning factors (C1: own, C2: social) (ok)
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue
float maxv = 0.1; // max velocidad (modulo)

// Constantes para el dominio del problema [-3,7]
float xMin = -3;
float xMax = 7;

class Particle {
  float x, y, fit; 
  float px, py, pfit; 
  float vx, vy; 
  
  // ---------------------------- Constructor
  Particle() {
    // Inicialización dentro del dominio [-3, 7] solicitado 
    x = random(xMin, xMax); 
    y = random(xMin, xMax);
    vx = random(-1, 1); 
    vy = random(-1, 1);
    
    // Inicializamos con un valor alto porque buscamos MINIMIZAR 
    pfit = 1000000; 
    fit = 1000000; 
  }
  
  // ---------------------------- Evalúa partícula
  // float Eval(PImage surf){ // Ya no recibe imagen, trabajo con el espacio restringido
  float Eval() { 
    evals++;
    
    // Función Rastrigin para n=2  (f(x) de la tarea
    // f(x) = 10*n + sum(xi^2 - 10*cos(2*PI*xi))
    // Hace el cálculo separado y luego al final los suma
    float term1 = pow(x, 2) - 10 * cos(TWO_PI * x);
    float term2 = pow(y, 2) - 10 * cos(TWO_PI * y);
    fit = 20 + term1 + term2; 

    // Actualiza local best si el fitness es MENOR (Minimización) 
    if (fit < pfit) { 
      pfit = fit;
      px = x;
      py = y;
    }
    
    // Actualiza global best si es MENOR 
    if (fit < gbest) { 
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
      println("Nuevo mejor fitness: " + str(gbest));
    }
    return fit;
  }
  
  // ------------------------------ mueve la partícula
  void move() {
     
    // PRUEBA 1: Solo factores de aprendizaje (Sin inercia)
    //vx = vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    //vy = vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
  
    // PRUEBA 2: Solo Inercia 
    vx = w * vx + random(0, 1) * (px - x) + random(0, 1) * (gbestx - x);
    vy = w * vy + random(0, 1) * (py - y) + random(0, 1) * (gbesty - y);
   
  
    //PRUEBA 3: actualiza velocidad (fórmula mezclada)
    //vx = w * vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    //vy = w * vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
   
    float modu = sqrt(vx * vx + vy * vy);
    if (modu > maxv) {
      vx = vx / modu * maxv;
      vy = vy / modu * maxv;
    }
    
    // Actualiza posición
    x = x + vx;
    y = y + vy;
    
    // Rebota en límites del dominio [-3, 7] 
    if (x > xMax || x < xMin) vx = -vx;
    if (y > xMax || y < xMin) vy = -vy;
    
    // Aseguramos que no salgan del dominio
    x = constrain(x, xMin, xMax);
    y = constrain(y, xMin, xMax);
  }
  
  // ------------------------------ despliega partícula
  void display() {
    // Mapeamos las coordenadas matemáticas [-3, 7] a los píxeles de la pantalla
    float renderX = map(x, xMin, xMax, 0, width);
    float renderY = map(y, xMin, xMax, height, 0); // invertido

    
    // color c=surf.get(int(x),int(y));
    fill(255, 150); // Color blanco semi-transparente
    ellipse(renderX, renderY, d, d);
    
    stroke(#ff0000);
    line(renderX, renderY, renderX - 10 * vx, renderY - 10 * vy);
  }
} 

void despliegaBest() {
  // Mapeo para el punto azul
  float bX = map(gbestx, xMin, xMax, 0, width);
  float bY = map(gbesty, xMin, xMax, height, 0);

  fill(#0000ff);
  ellipse(bX, bY, d, d);
  
  PFont f = createFont("Arial", 16, true);
  textFont(f, 15);
  fill(#00ff00);
  text("Best fitness (Min): " + str(gbest) + 
       "\nPos: [" + nf(gbestx, 0, 2) + ", " + nf(gbesty, 0, 2) + "]" +
       "\nEvals to best: " + str(evals_to_best) + 
       "\nEvals: " + str(evals), 10, 20);
}

// ===============================================================

void setup() {  
  size(600, 600); // Tamaño de ventana para visualización
  smooth();
  
  surf = loadImage("mapa_calor.png");

  // Inicializamos gbest con un valor muy alto para que cualquier primer evaluación sea mejor
  gbest = 1000000;
  
  fl = new Particle[puntos];
  for (int i = 0; i < puntos; i++)
    fl[i] = new Particle();
}

void draw() {
  background(50);
  

  // Usamos width y height para que se estire al tamaño de la ventana
  if (surf != null) {
    image(surf, 0, 0, width, height); 
  }  
  // image(surf,0,0); 
  for (int i = 0; i < puntos; i++) {
    fl[i].display();
  }
  despliegaBest();
  
  for (int i = 0; i < puntos; i++) {
    fl[i].move();
    // fl[i].Eval(surf);
    fl[i].Eval(); 
  }
}
