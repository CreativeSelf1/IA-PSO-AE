# PSO (Particle Swarm Optimization)

Este proyecto implementa el algoritmo de optimización por enjambre de partículas (PSO, por sus siglas en inglés), una metaheurística poblacional inspirada en el comportamiento social de bandadas de aves o cardúmenes de peces.

## ¿Qué hace?
El PSO busca la solución óptima a un problema de minimización (en este caso, la función de Rastrigin) utilizando un grupo (enjambre) de partículas que exploran el espacio de búsqueda. Cada partícula ajusta su posición y velocidad basándose en su experiencia personal y la del grupo, colaborando para encontrar el mejor resultado posible.

## Funcionamiento
En lugar de que un solo "agente" busque la solución, tienes un enjambre de partículas que "vuelan" sobre el espacio de búsqueda. Cada partícula ajusta su trayectoria basándose en dos fuentes de información:

- **Su propia experiencia:** El mejor lugar donde ella ha estado antes (pfit).
- **La experiencia del grupo:** El mejor lugar donde cualquier partícula del enjambre haya estado (gbest).

## Parámetros de Control
- **w (Inercia):** Determina cuánto afecta la velocidad anterior al movimiento actual. Un valor alto favorece la exploración (recorrer áreas nuevas), mientras que un valor bajo favorece la explotación (buscar cerca de soluciones conocidas).
- **C1 (Factor Cognitivo):** Peso que la partícula le da a su mejor resultado personal (pfit). Controla la "autonomía" de la partícula.
- **C2 (Factor Social):** Peso que la partícula le da al mejor resultado del grupo (gbest). Controla la "obediencia" al líder del enjambre.
- **maxv (Velocidad Máxima):** Límite para evitar que las partículas "salten" demasiado lejos y se salgan del área de interés o se vuelvan inestables.

## Variables de Aptitud (Fitness)
- **fitness / fit:** Valor numérico que devuelve la función Rastrigin para una posición (x, y).
- **pfit (Personal Best Fitness):** El valor de fitness más bajo (mejor) que esa partícula específica ha encontrado desde que empezó la simulación.
- **gbest (Global Best Fitness):** El valor de fitness más bajo encontrado por todo el enjambre. Es el récord absoluto del grupo.

## Variables de Posición
- **x, y:** Coordenadas actuales de la partícula en el dominio matemático [-3, 7].
- **px, py:** Ubicación exacta donde la partícula obtuvo su pfit.
- **gbestx, gbesty:** Coordenadas del punto que tiene el mejor fitness de todo el grupo (la posición del punto azul).
- **vx, vy:** Vector de velocidad actual, indica hacia dónde y qué tan rápido se moverá la partícula en el siguiente paso.

---
Este proyecto es ideal para experimentar y visualizar el comportamiento del PSO en problemas de optimización.
# IA-PSO-AE