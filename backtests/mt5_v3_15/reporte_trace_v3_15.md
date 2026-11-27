# Auditoría de Traza — Nova Bot `v3.15` (Experimento Descartado)

- **Archivo analizado:** `Nova_v3_trace_mt5_v3_15.csv` (`20,861` eventos, `2023.01.03` – `2026.11`)
- **Estado:** **DESCARTADA** (archivada en `archive/Nova_Bot_v3_15.mq5`). El repositorio vuelve a **`v3.13`** como versión principal.

---

## 1. Resumen Comparativo (`v3.13` Base vs `v3.14` vs `v3.15`)

| Métrica (`2023 – 2026`) | **`v3.13` (Principal)** | `v3.14` (`mt5_v3_14/`) | `v3.15` (`mt5_v3_15/`) | Diagnóstico |
| :--- | :---: | :---: | :---: | :--- |
| **Ganancia Neta (`R` / `%` @ `0.5%`)** | **`~+60.4R` (`+30.20%`)** | `+31.14R` (`+16.18%`) | `+22.34R` (`+11.17%`) | Caída acumulada de `-38R` frente a `v3.13` |
| **Profit Factor** | **`1.26`** | `1.14` | `1.12` (`+212.57R` / `-190.23R`) | Deterioro continuo de expectativa por trade |
| **Operaciones Cerradas** | `1,013` | `999` | `774` | — |
| **Win Rate (`> +0.02R`)** | **`44.72%`** | `39.74%` | `35.01%` | Caída de casi `10 pp` de tasa de acierto |
| **Rendimiento `2023`** | Positivo fuerte | `+19.36R` | `+14.90R` (`206` tr) | — |
| **Rendimiento `2024`** | Positivo sostenido | `+12.83R` | `+21.98R` (`197` tr) | — |
| **Rendimiento `2025`** | Positivo / DD acotado | `+0.23R` | **`-12.19R` (`204` tr)** | Fuerte pérdida en régimen 2025 |
| **Rendimiento `2026`** | Recuperación a máximos | `-1.29R` | **`-2.36R` (`167` tr)** | Negativo en 2026 |

---

## 2. Causas de la Degradación en `v3.15`

1. **Aumento severo de stops completos (`INIT_SL`: `94` trades = `-94.16R`):**
   - Al desactivar tanto el cierre por hora de gracia (`v3.13`) como el micro-swing a los `60m` (`InpGraceMicroSwing = false`), las operaciones que quedaban por debajo de `-0.25R` a la hora terminaron golpeando el `-1.00R` completo, sumado a `298` salidas en `*_GRACE_SL025` (`-74.50R`).
2. **Asfixia de recorridos medios al liberar fractales sin `BOS` desde `+1.00R`:**
   - Permitir cualquier fractal M5 desde `+1.00R` sin `BOS` y fijar un piso rígido `+1.25R -> +0.60R` cortó prematuramente continuaciones en `2023` y `2025–2026` sin compensar las pérdidas de las entradas estancadas.

## 3. Decisión de Ingeniería

En lugar de seguir parchando heurísticas a ciegas sobre `TRAIL_M5_SWING`, se restaura **`v3.13`** como **versión principal oficial** en `main` (`Nova_Bot_v3.mq5`) y se utilizará una **auditoría manual trade por trade de 1 mes** contra el backtest de `v3.13` para identificar con precisión quirúrgica únicamente diferencias reales verificadas.
