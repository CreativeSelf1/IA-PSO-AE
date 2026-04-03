"""
graficas.py
-----------
Genera gráficas de convergencia PSO a partir de los CSV producidos por Processing.

Puede ejecutarse desde CUALQUIER ubicación:
  - Desde la carpeta del sketch:   python resultados/graficas.py
  - Desde la carpeta resultados:   python graficas.py

Requiere: numpy, pandas, matplotlib
Instalar: pip install numpy pandas matplotlib
"""

import os
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

# ---------------------------------------------------------------
# DETECCIÓN AUTOMÁTICA DE RUTAS
# ---------------------------------------------------------------
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def find_base():
    for candidate in [
        SCRIPT_DIR,
        os.path.join(SCRIPT_DIR, "resultados"),
        os.getcwd(),
        os.path.join(os.getcwd(), "resultados"),
    ]:
        if any(os.path.isdir(os.path.join(candidate, d))
               for d in ("exploracion", "explotacion", "balanceada")):
            return candidate
    return SCRIPT_DIR

BASE_PATH  = find_base()
OUTPUT_DIR = os.path.join(BASE_PATH, "graficas")

CONFIGS = {
    "Exploración": "exploracion",
    "Explotación": "explotacion",
    "Balanceada":  "balanceada",
}

COLOR_BEST = "#1a3f6f"
COLOR_AVG  = "#c0392b"
PALETTE    = ["#1a3f6f", "#c0392b", "#1a7a4a"]

# ---------------------------------------------------------------
# CARGA DE DATOS
# ---------------------------------------------------------------
def load_runs(subfolder):
    path  = os.path.join(BASE_PATH, subfolder)
    files = sorted(glob.glob(os.path.join(path, "*.csv")))
    if not files:
        print(f"  [AVISO] No hay CSV en: {path}")
        return None, None

    bests, avgs = [], []
    for f in files:
        try:
            df = pd.read_csv(f)
            bests.append(df["best"].values.astype(float))
            avgs.append(df["average"].values.astype(float))
        except Exception as e:
            print(f"  [ERROR] {os.path.basename(f)}: {e}")

    if not bests:
        return None, None

    min_len = min(len(b) for b in bests)
    return (np.array([b[:min_len] for b in bests]),
            np.array([a[:min_len] for a in avgs]))


# ---------------------------------------------------------------
# ESTILO BASE
# ---------------------------------------------------------------
def style_ax(ax, log_scale=False):
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.grid(True, which="major", linestyle="--", linewidth=0.6,
            alpha=0.5, color="#bbbbbb")
    if log_scale:
        ax.grid(True, which="minor", linestyle=":", linewidth=0.4,
                alpha=0.3, color="#cccccc")
        ax.yaxis.set_minor_locator(ticker.LogLocator(subs="all", numticks=10))
    ax.tick_params(labelsize=10)


# ---------------------------------------------------------------
# GRÁFICA INDIVIDUAL  (lineal izq | logarítmica der)
# ---------------------------------------------------------------
def plot_single(config_name, subfolder):
    bests, avgs = load_runs(subfolder)
    if bests is None:
        return None, None

    n_runs, n_iter = bests.shape
    iters     = np.arange(n_iter)
    mean_best = bests.mean(axis=0)
    std_best  = bests.std(axis=0)
    mean_avg  = avgs.mean(axis=0)

    fig, (ax_lin, ax_log) = plt.subplots(1, 2, figsize=(14, 5.5))
    fig.suptitle(f"PSO – {config_name}  ({n_runs} ejecuciones)",
                 fontsize=13, y=1.01)

    for ax, log in [(ax_lin, False), (ax_log, True)]:
        # Banda ±1 std solo en escala lineal (en log puede quedar raro)
        if not log:
            ax.fill_between(iters,
                            np.maximum(mean_best - std_best, 0),
                            mean_best + std_best,
                            alpha=0.15, color=COLOR_BEST)

        ax.plot(iters, mean_best, color=COLOR_BEST, linewidth=1.8, label="best")
        ax.plot(iters, mean_avg,  color=COLOR_AVG,  linewidth=1.5, label="average")

        ax.set_xlabel("Iteración", fontsize=11)
        ax.set_ylabel("f(x) – Rastrigin" + (" (log)" if log else ""), fontsize=11)
        ax.set_xlim(0, n_iter - 1)

        if log:
            ax.set_yscale("log")
            ax.set_title("Escala logarítmica", fontsize=11)
            # Piso mínimo: evitar log(0)
            pos_vals = mean_best[mean_best > 0]
            floor = pos_vals.min() * 0.5 if len(pos_vals) else 1e-6
            ax.set_ylim(bottom=floor)
        else:
            ax.set_ylim(bottom=0)
            ax.set_title("Escala lineal", fontsize=11)

        leg = ax.legend(loc="upper right", fontsize=10,
                        framealpha=0.9, edgecolor="#cccccc")
        for line in leg.get_lines():
            line.set_linewidth(2.5)

        style_ax(ax, log_scale=log)

    plt.tight_layout()
    safe = subfolder.lower()
    out  = os.path.join(OUTPUT_DIR, f"convergencia_{safe}.png")
    plt.savefig(out, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"  Guardada: {out}")
    return mean_best, mean_avg


# ---------------------------------------------------------------
# GRÁFICA COMPARATIVA  (lineal izq | logarítmica der)
# ---------------------------------------------------------------
def plot_comparison(all_means):
    valid = {k: v for k, v in all_means.items() if v is not None}
    if not valid:
        print("  [AVISO] Sin datos para gráfica comparativa.")
        return

    fig, (ax_lin, ax_log) = plt.subplots(1, 2, figsize=(14, 5.5))
    fig.suptitle("Comparación configuraciones PSO – mejor fitness (media 30 runs)",
                 fontsize=12, y=1.01)

    for ax, log in [(ax_lin, False), (ax_log, True)]:
        for (name, mean_best), color in zip(valid.items(), PALETTE):
            ax.plot(np.arange(len(mean_best)), mean_best,
                    color=color, linewidth=1.8, label=name)

        max_iter = max(len(v) for v in valid.values())
        ax.set_xlabel("Iteración", fontsize=11)
        ax.set_ylabel("Mejor fitness promedio" + (" (log)" if log else ""), fontsize=11)
        ax.set_xlim(0, max_iter - 1)

        if log:
            ax.set_yscale("log")
            ax.set_title("Escala logarítmica", fontsize=11)
            all_pos = np.concatenate([v[v > 0] for v in valid.values()
                                      if (v > 0).any()])
            if len(all_pos):
                ax.set_ylim(bottom=all_pos.min() * 0.5)
        else:
            ax.set_ylim(bottom=0)
            ax.set_title("Escala lineal", fontsize=11)

        leg = ax.legend(loc="upper right", fontsize=10,
                        framealpha=0.9, edgecolor="#cccccc")
        for line in leg.get_lines():
            line.set_linewidth(2.5)

        style_ax(ax, log_scale=log)

    plt.tight_layout()
    out = os.path.join(OUTPUT_DIR, "comparacion_configuraciones.png")
    plt.savefig(out, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"  Guardada: {out}")


# ---------------------------------------------------------------
# TABLA RESUMEN
# ---------------------------------------------------------------
def print_summary(all_data):
    print("\n" + "=" * 70)
    print(f"{'Config':<14} {'Runs':>5} {'Media final':>14} {'±Std':>10} "
          f"{'Mín':>10} {'Máx':>10}")
    print("-" * 70)
    for name, (bests, _) in all_data.items():
        if bests is None:
            print(f"{name:<14}  sin datos")
            continue
        f = bests[:, -1]
        print(f"{name:<14} {len(f):>5} {f.mean():>14.6f} {f.std():>10.6f} "
              f"{f.min():>10.6f} {f.max():>10.6f}")
    print("=" * 70 + "\n")


# ---------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------
if __name__ == "__main__":
    print(f"\nBase de datos  : {BASE_PATH}")
    print(f"Salida gráficas: {OUTPUT_DIR}\n")
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    all_means, all_data = {}, {}

    for name, subfolder in CONFIGS.items():
        print(f"[{name}]")
        bests, avgs = load_runs(subfolder)
        all_data[name] = (bests, avgs)
        mean_best, _ = plot_single(name, subfolder)
        all_means[name] = mean_best

    print("\n[Comparación]")
    plot_comparison(all_means)

    print_summary(all_data)
    print("¡Listo! Revisa la carpeta 'graficas/'.")
