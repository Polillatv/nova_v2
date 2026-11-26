# Reporte Maestro de Rendimiento - Nova_Bot_v3.2 (`Nova_Bot_v3_2`)

## 1. Resumen Ejecutivo y Comparativa Evolutiva (`v3` vs. `v3.11` vs. `v3.2`)

Comparación directa de las tres iteraciones de la generación **v3** bajo exactamente las mismas condiciones de simulación (`NAS100 M5`, calidad `99%`, `185,005,859` ticks, depósito inicial `100,000.00` USD):

| Métrica Clave | Nova_Bot_v3 | Nova_Bot_v3.11 | Nova_Bot_v3.2 | Destacado / Lectura |
| :--- | :---: | :---: | :---: | :--- |
| **Beneficio Neto** | **+$30,671.66 (+30.67%)** | +$27,704.44 (+27.70%) | +$26,488.50 (+26.49%) | `v3` lidera en retorno absoluto |
| **Profit Factor** | **1.27** | 1.24 | 1.23 | `v3` lidera en eficiencia bruta |
| **Equity Drawdown Máx.** | 7.90% ($10,020.00) | 8.06% ($10,164.98) | **7.72% ($9,730.28)** | **`v3.2` logra el menor DD** |
| **Balance Drawdown Máx.** | 7.50% ($9,489.68) | 7.66% ($9,634.66) | **7.32% ($9,199.96)** | **`v3.2` logra el menor DD** |
| **Ratio de Sharpe** | 3.64 | **3.92** | 3.59 | `v3.11` lidera en Sharpe |
| **LR Standard Error** | 3,445.82 | 3,247.90 | **3,209.01** | **`v3.2` curva más lineal/suave** |
| **Total Operaciones** | 1,010 | **1,015** | 1,013 | Volumen estable (~1,010 trades) |
| **Win Rate Global** | 44.65% | **44.73%** | 44.62% | Consistente en ~44.7% |
| **Expected Payoff** | **$30.37** | $27.30 | $26.15 | `v3` mayor ganancia media/trade |
| **Solo S2 Nacimiento (Pass 2)** | **+$4,911.93 (PF 1.18)** | +$1,478.72 (PF 1.05) | +$2,345.65 (PF 1.09) | `v3.2` recupera parte de S2N |
| **Solo S2 Cont (Pass 4)** | +$7,931.37 (PF 1.49) | **+$8,980.69 (PF 1.55)** | +$8,004.96 (PF 1.49) | Muy sólido en las 3 versiones |
| **S1 + S2 Cont (Pass 5)** | +$22,282.80 (PF 1.27) | **+$24,403.70 (PF 1.29)** | +$21,956.42 (PF 1.27) | `v3.11` destaca en combo S1+S2C |

### Síntesis de Posicionamiento de `v3.2`

* **Máxima contención de riesgo y linealidad:** `Nova_Bot_v3_2` registra el **menor Drawdown máximo** de toda la familia v3 (`7.32%` en balance y `7.72%` en equidad) y el menor error estándar de regresión lineal (`LR Standard Error: 3,209.01`), manteniendo una correlación de curva de `0.90`.
* **Equilibrio entre motores:** Recupera el rendimiento de `Setup 2 Nacimiento` respecto a `v3.11` (subiendo su Profit Factor de `1.05` a `1.09`), mientras conserva a `Setup 2 Continuación` en `1.49 PF` (`3.29%` DD) y a `Setup 1` en `1.22 PF` (`6.96%` DD).

## 2. Desglose por Combinación de Setups (Optimización v3.2)

| Paso (Pass) | Combinación Activa | Resultado (PF) | Beneficio Neto | Operaciones | Beneficio Esperado | Reducción % (DD) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **4** | **Solo `Setup 2 Continuación`** | **1.49** | +$8,004.96 | 163 | **$49.11** | **3.29%** |
| **5** | **`Setup 1` + `Setup 2 Cont`** | **1.27** | +$21,956.42 | 781 | $28.11 | 6.89% |
| **6** | **`Setup 2 Nac` + `Setup 2 Cont`** | **1.23** | +$10,511.07 | 391 | $26.88 | 6.65% |
| **7** | **Todos activos (`S1` + `S2N` + `S2C`)** | **1.22** | **+$24,891.09** | **1,009** | $24.67 | 7.66% |
| **1** | **Solo `Setup 1`** | **1.22** | +$15,512.97 | 698 | $22.22 | 6.96% |
| **3** | **`Setup 1` + `Setup 2 Nac`** | **1.18** | +$18,265.21 | 926 | $19.72 | 7.52% |
| **2** | **Solo `Setup 2 Nacimiento`** | **1.09** | +$2,345.65 | 228 | $10.29 | 5.42% |
| **0** | Ninguno activo | 0.00 | $0.00 | 0 | $0.00 | 0.00% |

## 3. Estadísticas Detalladas del Backtest (Calidad 99%)

* **Entorno de Simulación:** `NAS100`, `M5` | Calidad de historial: `99%` (`275,862` barras / `185,005,859` ticks).
* **Capital y Retorno:** Depósito inicial `100,000.00` $\rightarrow$ Balance final `126,488.50` (`+26.49%`).
* **Beneficio Bruto vs. Pérdida Bruta:** `+$141,405.56` vs. `-$114,917.06`.
* **Control de Drawdown:**
  * Balance Máximo: `9,199.96` (`7.32%`) | Balance Absoluto: `1,755.03`
  * Equidad Máxima: `9,730.28` (`7.72%`) | Equidad Absoluta: `1,885.59`
* **Calidad Estadística:**
  * **Factor de Beneficio:** `1.23` | **Factor de Recuperación:** `2.72`
  * **Ratio de Sharpe:** `3.59` | **Z-Score:** `0.75` (`54.67%`)
  * **LR Correlation:** `0.90` | **LR Standard Error:** `3,209.01`
* **Distribución de Operaciones:**
  * **Total Operaciones:** `1,013` (`2,026` transacciones)
  * **Posiciones Largas:** `573` (`46.77%` ganadoras) | **Posiciones Cortas:** `440` (`41.82%` ganadoras)
  * **Win Rate Global:** `44.62%` (`452` ganadoras / `561` perdedoras)
  * **Ratio Riesgo/Beneficio Real:** Ganancia media `+$312.84` vs. Pérdida media `-$204.84` (**Ratio `1.53 : 1`**).
  * **Extremos:** Mayor ganancia `+$1,542.01` | Mayor pérdida `-$630.63`.
  * **Rachas:** Máx. ganancias seguidas `7` (`+$1,391.33`, pico monetario `+$3,713.41` en `5` trades) | Máx. pérdidas seguidas `9` (`-$1,843.78`).

## 4. Análisis Temporal y Curva de Equidad

* **Estacionalidad Mensual y Semanal:** **11 de los 12 meses cierran en positivo** (solo septiembre cierra ligeramente negativo) y **5 de 5 días de la semana cierran en ganancia neta**, destacando el **jueves** (`~$37,000` brutos vs. `~$22,500` pérdidas).
* **Correlación MFE / MAE:** `Profits vs. MFE = 0.85` | `Profits vs. MAE = 0.64` | `MFE vs. MAE = 0.3585`.
* **Cronología (`2023.01.11` – `2026.10.12`):** Impulso en H1 2023 (`~110,200`), consolidación lateral en H2 2023–Q1 2024, expansión sostenida hasta `~125,798` en Q1 2025, retroceso controlado hasta `~116,073` a finales de 2025 (`7.72%` DD máximo en equidad) y recuperación continua en 2026 cerrando en `126,488.50` USD, con carga de depósito siempre inferior al `1.0%`.