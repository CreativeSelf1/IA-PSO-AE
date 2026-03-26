import pandas as pd
import matplotlib.pyplot as plt
import glob
import os

def plot_single_csv(filename):
    df = pd.read_csv(filename)
    base_name = os.path.splitext(filename)[0]

    # Gráfico combinado Best vs Average
    plt.figure(figsize=(10, 6))
    plt.plot(df["iter"], df["best"], label="Best fitness", linewidth=2)
    plt.plot(df["iter"], df["average"], label="Average fitness", alpha=0.7)
    plt.xlabel("Iteración")
    plt.ylabel("Fitness")
    plt.title(f"Convergencia PSO\n({filename})")
    plt.grid(True, linestyle='--', alpha=0.6)
    plt.legend()
    plt.savefig(f"{base_name}_convergencia.png", dpi=300)
    plt.close() # Cerrar para ahorrar memoria

def compare_configs(csv_files):
    plt.figure(figsize=(12, 7))
    
    for file in csv_files:
        df = pd.read_csv(file)
        # Extraer etiqueta del nombre del archivo (ej: fija o aleatoria)
        label = os.path.splitext(file)[0].replace("pso_", "")
        plt.plot(df["iter"], df["best"], label=f"Best: {label}")

    plt.yscale('log') # Escala logarítmica suele ser mejor para Rastrigin
    plt.xlabel("Iteración")
    plt.ylabel("Best fitness (log scale)")
    plt.title("Comparación: Semilla Fija vs Semilla Aleatoria")
    plt.grid(True, which="both", ls="-", alpha=0.5)
    plt.legend()
    plt.savefig("comparativa_fija_vs_aleatoria.png", dpi=300)
    print("[OK] Gráfico comparativo guardado: comparativa_fija_vs_aleatoria.png")

if __name__ == "__main__":
    # Buscar archivos generados por el nuevo formato
    csv_files = glob.glob("pso_*.csv")

    if not csv_files:
        print("No se encontraron archivos pso_*.csv. Ejecuta primero Processing.")
        exit()

    for file in csv_files:
        plot_single_csv(file)

    if len(csv_files) >= 2:
        compare_configs(csv_files)
    
    print(f"Procesados {len(csv_files)} archivos.")
