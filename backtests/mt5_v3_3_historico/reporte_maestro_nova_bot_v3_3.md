# Reporte Maestro de Rendimiento - Nova_Bot_v3.3 (`Nova_Bot_v3`)

## 1. Resumen Ejecutivo y Comparativa Evolutiva (`v3` vs. `v3.11` vs. `v3.2` vs. `v3.3`)

Comparación directa de las cuatro iteraciones de la generación **v3** bajo las mismas condiciones de simulación (`NAS100 M5`, calidad `99%`, `185,005,859` ticks, depósito inicial `100,000.00` USD):

| Métrica Clave | Nova_Bot_v3 | Nova_Bot_v3.11 | Nova_Bot_v3.2 | Nova_Bot_v3.3 (Actual) | Ganador / Lectura |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Beneficio Neto** | **+$30,671.66** | +$27,704.44 | +$26,488.50 | **+$30,198.83 (+30.20%)** | Prácticamente empate en cima (+$30k) |
| **Equity Drawdown Máx.** | 7.90% ($10,020) | 8.06% ($10,165) | 7.72% ($9,730) | **7.18% ($9,179.52)** | **`v3.3` récord menor DD** |
| **Balance Drawdown Máx.** | 7.50% ($9,490) | 7.66% ($9,635) | 7.32% ($9,200) | **6.78% ($8,644.62)** | **`v3.3` récord menor DD** |
| **Ratio de Sharpe** | 3.64 | 3.92 | 3.59 | **4.01** | **`v3.3` rompe barrera de 4.0** |
| **Factor de Recuperación** | 3.06 | 2.73 | 2.72 | **3.29** | **`v3.3` récord resiliencia** |
| **Profit Factor** | **1.27** | 1.24 | 1.23 | **1.26** | Virtualmente igual al máximo |
| **LR Correlation** | 0.90 | 0.90 | 0.90 | **0.92** | **`v3.3` mayor linealidad** |
| **LR Standard Error** | 3,445.82 | 3,247.90 | 3,209.01 | **3,184.17** | **`v3.3` menor dispersión** |
| **Total Operaciones** | 1,010 | 1,015 | 1,013 | **1,013** | Muestra altamente consistente |
| **Expected Payoff** | **$30.37** | $27.30 | $26.15 | **$29.81** | Excelente retorno medio/trade |
| **Solo S2 Nacimiento (Pass 2)** | **+$4,911.93 (1.18)** | +$1,478.72 (1.05) | +$2,345.65 (1.09) | **+$4,911.93 (PF 1.18)** | **Recupera 100% fuerza S2N** |
| **Solo S2 Cont (Pass 4)** | +$7,931.37 (1.49) | **+$8,980.69 (1.55)** | +$8,004.96 (1.49) | **+$8,243.94 (PF 1.51)** | **PF 1.51 con solo 3.27% DD** |

### Diagnóstico Clave de `v3.3` (La Versión Más Equilibrada)

* **Combina el techo de rentabilidad de `v3` con la estabilidad máxima:** Mantiene intacto el bloque de **+$30,198.83** de beneficio neto (`PF 1.26`) al recuperar la potencia total de `Setup 2 Nacimiento` (`+$4,911.93`, `PF 1.18`), pero recortando el **Equity Drawdown máximo de `7.90%` a `7.18%`** (`-$840` menos de caída máxima).
* **Mejora en todos los indicadores institucionales de riesgo:** Supera a todas las versiones previas en **Ratio de Sharpe (`4.01`)**, **Factor de Recuperación (`3.29`)**, **LR Correlation (`0.92`)** y **LR Standard Error (`3,184.17`)**.

## 2. Desglose por Combinación de Setups (Optimización v3.3)

| Paso (Pass) | Combinación Activa | Resultado (PF) | Beneficio Neto | Operaciones | Beneficio Esperado | Reducción % (DD) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **4** | **Solo `Setup 2 Continuación`** | **1.51** | +$8,243.94 | 163 | **$50.58** | **3.27%** |
| **6** | **`Setup 2 Nac` + `Setup 2 Cont`** | **1.29** | +$13,587.83 | 391 | $34.75 | 5.33% |
| **5** | **`Setup 1` + `Setup 2 Cont`** | **1.27** | +$22,538.31 | 781 | $28.86 | 6.92% |
| **7** | **Todos activos (`S1` + `S2N` + `S2C`)** | **1.24** | **+$28,549.46** | **1,009** | $28.29 | 7.03% |
| **1** | **Solo `Setup 1`** | **1.23** | +$16,158.06 | 698 | $23.15 | 6.80% |
| **3** | **`Setup 1` + `Setup 2 Nac`** | **1.21** | +$21,813.02 | 926 | $23.56 | 6.72% |
| **2** | **Solo `Setup 2 Nacimiento`** | **1.18** | +$4,911.93 | 228 | $21.54 | 4.44% |
| **0** | Ninguno activo | 0.00 | $0.00 | 0 | $0.00 | 0.00% |

## 3. Estadísticas Detalladas del Backtest (Calidad 99%)

* **Entorno de Simulación:** `NAS100`, `M5` | Calidad de historial: `99%` (`275,862` barras / `185,005,859` ticks).
* **Capital y Retorno:** Depósito inicial `100,000.00` $\rightarrow$ Balance final `130,198.83` (`+30.20%`).
* **Beneficio Bruto vs. Pérdida Bruta:** `+$146,093.23` vs. `-$115,894.40`.
* **Control de Drawdown:**
  * Balance Máximo: `8,644.62` (`6.78%`) | Balance Absoluto: `1,698.79`
  * Equidad Máxima: `9,179.52` (`7.18%`) | Equidad Absoluta: `1,829.35`
* **Calidad Estadística:**
  * **Factor de Beneficio:** `1.26` | **Factor de Recuperación:** `3.29`
  * **Ratio de Sharpe:** `4.01` | **Z-Score:** `0.61` (`45.81%`)
  * **LR Correlation:** `0.92` | **LR Standard Error:** `3,184.17`
* **Distribución de Operaciones:**
  * **Total Operaciones:** `1,013` (`2,026` transacciones)
  * **Posiciones Largas:** `574` (`46.86%` ganadoras) | **Posiciones Cortas:** `439` (`41.91%` ganadoras)
  * **Win Rate Global:** `44.72%` (`453` ganadoras / `560` perdedoras)
  * **Ratio Riesgo/Beneficio Real:** Ganancia media `+$322.50` vs. Pérdida media `-$206.95` (**Ratio `1.56 : 1`**).
  * **Extremos:** Mayor ganancia `+$2,444.17` | Mayor pérdida `-$647.66`.
  * **Rachas:** Máx. ganancias seguidas `7` (`+$1,430.06`, pico monetario `+$4,225.56` en `5` trades) | Máx. pérdidas seguidas `9` (`-$1,845.81`).

## 4. Análisis Temporal y Curva de Equidad

* **Estacionalidad Mensual y Semanal:** **11 de los 12 meses cierran en positivo** (solo septiembre queda prácticamente plano/levemente negativo) y **4 de 5 días de la semana cierran fuertemente en positivo** (lunes a jueves, liderados por el **jueves** con `~$38,000` brutos vs. `~$23,750` pérdidas; viernes prácticamente plano).
* **Correlación MFE / MAE:** `Profits vs. MFE = 0.86` | `Profits vs. MAE = 0.63` | `MFE vs. MAE = 0.3524`.
* **Cronología (`2023.01.17` – `2026.08.17`):** Impulso en H1 2023 (`~110,482`), consolidación lateral controlada en H2 2023–Q1 2024, expansión sostenida hasta `~127,945` en Q1 2025, retroceso acotado hasta `~119,214` a finales de 2025 (`7.18%` DD máximo en equidad) y recuperación continua en 2026 cerrando en `130,198.83` USD, con carga de depósito siempre inferior al `1.0%`.