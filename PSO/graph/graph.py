import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Rango
x = np.linspace(-3, 7, 400)
y = np.linspace(-3, 7, 400)

# Malla
X, Y = np.meshgrid(x, y)

# Función Rastrigin
Z = 20 + (X**2 - 10*np.cos(2*np.pi*X)) + (Y**2 - 10*np.cos(2*np.pi*Y))

fig = plt.figure(figsize=(12,5))

# --- Superficie 3D ---
ax = fig.add_subplot(1,2,1, projection='3d')
ax.plot_surface(X, Y, Z)
ax.set_title("Superficie 3D")
ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_zlabel("Z")

# --- Heatmap ---
ax2 = fig.add_subplot(1,2,2)
heatmap = ax2.imshow(
    Z,
    extent=[-3,7,-3,7],
    origin="lower",
    aspect="auto",
    vmin=0,      # mínimo del color
    vmax=120     # máximo del color (umbral)
)

ax2.set_title("Mapa de calor")
ax2.set_xlabel("X")
ax2.set_ylabel("Y")

fig.colorbar(heatmap)

plt.show()

