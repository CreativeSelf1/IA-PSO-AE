# Proyecto IA - Optimización (PSO y Algoritmos Evolutivos)

Este proyecto contiene la implementación y análisis de dos algoritmos de optimización heurística aplicados sobre una función de evaluación (representada visualmente en un mapa de calor):

1. **PSO** (Optimización por Enjambre de Partículas / *Particle Swarm Optimization*)
2. **AE** (Algoritmos Evolutivos)

Ambos algoritmos se encuentran estructurados en directorios separados (`/PSO` y `/AE`) y han sido implementados para experimentar con diferentes perfiles de comportamiento utilizando archivos de configuración sin necesidad de modificar el código principal.

---

## Configuraciones mediante archivos JSON

El comportamiento y los parámetros de los algoritmos se controlan fácilmente a través de archivos `.json`:
- **PSO utiliza**: `PSO/config.json`
- **AE utiliza**: `AE/config_ea.json`

### ¿Cómo funcionan?
En lugar de tener los parámetros en el código fuente, al iniciar la ejecución, los programas leen el archivo configuración correspondiente. Dentro de este archivo se definen diferentes "escenarios" o perfiles (por ejemplo: `exploracion`, `explotacion` y `balanceada`). 

Dependiendo del algoritmo, los parámetros que se cargan incluyen:
- **Para PSO**: Parámetros de la ecuación de movimiento de las partículas, como la inercia (`w`), los factores cognitivo y social (`c1` y `c2`), la velocidad máxima (`maxv`), número de partículas, entre otros.
- **Para AE**: Hiperparámetros evolutivos, como el tamaño de la población (`popSize`), la presión del torneo para la selección (`kTorneo`), probabilidades de cruce (`pCrossover`), factores combinatorios (`alphaBLX`), atributos de mutación gausiana (`pMutacion` y `sigma`), y la cantidad de individuos para elitismo.

Cada bloque de configuración de estos `.json` cuenta con un campo crítico llamado `"ruta_salida"`. Este parámetro define la ruta del directorio específico donde se almacenará automáticamente la información tras ejecutar dicha configuración.

---

## Resultados (Archivos CSV) y Gráficas de Análisis

Una vez finalizadas las ejecuciones en Processing/Java para cualquiera de los perfiles:
1. **Generación de Archivos `.csv`**: El estado del algoritmo, las ubicaciones, evoluciones y la aptitud (fitness o best value) alcanzadas en diferentes iteraciones y ejecuciones son exportados automáticamente a la carpeta definida en `"ruta_salida"` de tu JSON.  
   - *Ejemplo PSO*: Se guardarán en rutas como `PSO/resultados/exploracion/`, `PSO/resultados/balanceada/`, etc.
   - *Ejemplo AE*: Se guardarán en rutas relativas como `AE/resultados_ea/explotacion/`, etc.

2. **Uso de `graficas.py`**: Para interpretar estos datos recopilados (los archivos `.csv`), en las respectivas carpetas de resultados (`PSO/resultados/` y `AE/resultados_ea/`) encontrarás un script creado en Python llamado **`graficas.py`**.
   
   Al ejecutar este script, se procesarán todos los datos históricos guardados en los CSV y se generarán las **curvas de convergencia** y demás **gráficas** correspondientes. De esta forma, resulta rápido y cómodo comparar visualmente, por ejemplo, cómo convergió el modelo con una configuración de *exploración pura* frente a uno de *explotación*.