# Reporte Maestro de Rendimiento - Nova_Bot_v3.11 (`Nova_Bot_v3_1`)

## 1. Resumen Ejecutivo y Comparativa (v3 vs. v3.11)

Comparación directa bajo las mismas condiciones de simulación (`NAS100 M5`, calidad `99%`, `185M` ticks, depósito inicial `100,000.00` USD):

| Métrica Clave | Nova_Bot_v3 (Backtest 99%) | Nova_Bot_v3.11 (Backtest 99%) | Diferencia / Lectura |
| :--- | :---: | :---: | :--- |
| **Beneficio Neto** | **+$30,671.66 (+30.67%)** | +$27,704.44 (+27.70%) | -$2,967.22 (-2.97%) |
| **Profit Factor** | **1.27** | 1.24 | -0.03 puntos |
| **Ratio de Sharpe** | 3.64 | **3.92** | **+0.28 (Mayor estabilidad)** |
| **LR Standard Error** | 3,445.82 | **3,247.90** | **Curva más suave (-$198 error)** |
| **Equity Drawdown Máx.** | **7.90% ($10,020.00)** | 8.06% ($10,164.98) | +0.16% (Prácticamente igual) |
| **Total Operaciones** | 1,010 | **1,015** | +5 operaciones |
| **Win Rate Global** | 44.65% | **44.73%** | +0.08% |
| **Expected Payoff** | **$30.37** | $27.30 | -$3.07 por operación |
| **Mejor Pass Individual (S2C)** | PF 1.49 / DD 3.37% | **PF 1.55 / DD 3.27%** | **Mejora en S2 Continuación** |
| **Pass 5 (S1 + S2 Cont)** | +$22,282.80 (PF 1.27 / DD 7.93%) | **+$24,403.70 (PF 1.29 / DD 6.69%)** | **Mejora clara en S1 + S2C** |

### Diagnóstico Clave entre Versiones

* **Salto en `Setup 1` y `Setup 2 Continuación`:** En `v3.11`, el combo **`Pass 5` (`Setup 1 + Setup 2 Continuación`)** mejora drásticamente respecto a `v3`: sube el beneficio neto de `$22,282.80` a **`$24,403.70`**, aumenta el Profit Factor a **`1.29`** y reduce el drawdown de `7.93%` a **`6.69%`**.
* **Debilitamiento puntual de `Setup 2 Nacimiento`:** El ligero retroceso del `Pass 7` completo (`$27,704.44` vs. `$30,671.66` en `v3`) proviene exclusivamente de **`Setup 2 Nacimiento` (`Pass 2`)**, que bajó de `+$4,911.93` (`PF 1.18`) en `v3` a `+$1,478.72` (`PF 1.05`) en `v3.11`.

## 2. Desglose por Combinación de Setups (Optimización v3.11)

| Paso (Pass) | Combinación Activa | Resultado (PF) | Beneficio Neto | Operaciones | Beneficio Esperado | Reducción % (DD) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **4** | **Solo `Setup 2 Continuación`** | **1.55** | +$8,980.69 | 163 | **$55.10** | **3.27%** |
| **5** | **`Setup 1` + `Setup 2 Cont`** | **1.29** | +$24,403.70 | 783 | $31.17 | 6.69% |
| **1** | **Solo `Setup 1`** | **1.24** | +$17,261.65 | 700 | $24.66 | 6.79% |
| **6** | **`Setup 2 Nac` + `Setup 2 Cont`** | **1.23** | +$10,607.68 | 391 | $27.13 | 6.67% |
| **7** | **Todos activos (`S1` + `S2N` + `S2C`)** | **1.23** | **+$26,325.82** | **1,011** | $26.04 | 7.83% |
| **3** | **`Setup 1` + `Setup 2 Nac`** | **1.18** | +$19,074.90 | 928 | $20.55 | 7.81% |
| **2** | **Solo `Setup 2 Nacimiento`** | **1.05** | +$1,478.72 | 228 | $6.49 | 5.13% |
| **0** | Ninguno activo | 0.00 | $0.00 | 0 | $0.00 | 0.00% |

## 3. Estadísticas Detalladas del Backtest (Calidad 99%)

* **Entorno de Simulación:** `NAS100`, `M5` | Calidad de historial: `99%` (`275,862` barras / `185,005,859` ticks).
* **Capital y Retorno:** Depósito inicial `100,000.00` $\rightarrow$ Balance final `127,704.44` (`+27.70%`).
* **Beneficio Bruto vs. Pérdida Bruta:** `+$142,540.54` vs. `-$114,836.10`.
* **Control de Drawdown:**
  * Balance Máximo: `9,634.66` (`7.66%`) | Balance Absoluto: `1,542.01`
  * Equidad Máxima: `10,164.98` (`8.06%`) | Equidad Absoluta: `1,672.57`
* **Calidad Estadística:**
  * **Ratio de Sharpe:** `3.92` | **Factor de Recuperación:** `2.73`
  * **LR Correlation:** `0.90` | **LR Standard Error:** `3,247.90`
  * **Z-Score:** `0.68` (`50.35%`) | **AHPR / GHPR:** `1.0002` (`0.02%`)
* **Distribución de Operaciones:**
  * **Total Operaciones:** `1,015` (`2,030` transacciones)
  * **Posiciones Largas:** `575` (`46.96%` ganadoras) | **Posiciones Cortas:** `440` (`41.82%` ganadoras)
  * **Win Rate Global:** `44.73%` (`454` ganadoras / `561` perdedoras)
  * **Ratio Riesgo/Beneficio Real:** Ganancia media `+$313.97` vs. Pérdida media `-$204.70` (**Ratio `1.53 : 1`**).
  * **Extremos:** Mayor ganancia `+$1,528.17` | Mayor pérdida `-$630.63`.
  * **Rachas:** Máx. ganancias seguidas `7` (`+$1,494.29`, pico monetario `+$3,505.40` en `4` trades) | Máx. pérdidas seguidas `9` (`-$1,845.81`).

## 4. Análisis Temporal y Curva de Equidad

* **Estacionalidad Mensual y Semanal:** **11 de los 12 meses cierran en positivo** (solo septiembre queda prácticamente plano/levemente negativo) y **5 de 5 días de la semana cierran en ganancia neta**, liderados por **miércoles** y **jueves**.
* **Correlación MFE / MAE:** `Profits vs. MFE = 0.85` | `Profits vs. MAE = 0.65` | `MFE vs. MAE = 0.3616`.
* **Cronología (`2023.01.13` – `2026.09.21`):** Impulso en H1 2023 (`~110,000`), consolidación lateral en H2 2023–Q1 2024, expansión sostenida hasta `~126,000` en Q1 2025, retroceso controlado hasta `~116,200` a finales de 2025 (`8.06%` DD) y recuperación continua en 2026 hacia máximos históricos (`127,704.44` USD), con carga de depósito siempre inferior al `1.0%`.