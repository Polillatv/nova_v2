# Reporte Maestro de Rendimiento - Nova_Bot v3.10 (`Nova_Bot_v3` Base)

## 1. Resumen Ejecutivo y Evolución (`v2.3` vs. `v3.10`)

La actualización hacia **Nova_Bot_v3** representa un salto cualitativo y cuantitativo significativo respecto a la versión anterior (`v2.3`) en el periodo completo de casi 4 años (`2023.01.11` – `2026.10.12` en `NAS100 M5`):

| Métrica Clave | Nova_Bot v2.3 (Pass 7) | Nova_Bot v3 (Backtest 99%) | Variación / Impacto |
| :--- | :--- | :--- | :--- |
| **Beneficio Neto** | +$8,416.59 (+8.42%) | **+$30,671.66 (+30.67%)** | **+264% de retorno neto** |
| **Profit Factor** | 1.10 | **1.27** | **+0.17 puntos** |
| **Equity Drawdown Máx.** | 8.93% | **7.90% ($10,020.00)** | **-1.03% menor riesgo** |
| **Total Operaciones** | 805 | **1,010** | +205 operaciones |
| **Expected Payoff** | $10.46 | **$30.37** | **Casi 3x por operación** |
| **Ratio de Sharpe** | — | **3.64** | Excelente estabilidad |
| **Factor de Recuperación** | — | **3.06** | Alta resiliencia |

---

## 2. Desglose por Combinación de Setups (Optimización)

Resultados obtenidos en el *Strategy Tester* ordenados por rentabilidad máxima (Profit Factor):

| Paso (Pass) | Combinación Activa | Resultado (PF) | Beneficio Neto | Operaciones | Beneficio Esperado | Reducción % (DD) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **4** | **Solo `Setup 2 Continuación`** | **1.49** | +$7,931.37 | 162 | **$48.96** | **3.37%** |
| **6** | **`Setup 2 Nac` + `Setup 2 Cont`** | **1.28** | +$13,219.00 | 390 | $33.89 | 5.16% |
| **5** | **`Setup 1` + `Setup 2 Cont`** | **1.27** | +$22,282.80 | 777 | $28.68 | 7.93% |
| **7** | **Todos activos (`S1` + `S2N` + `S2C`)** | **1.24** | **+$27,999.87** | **1,005** | $27.86 | 8.09% |
| **1** | **Solo `Setup 1`** | **1.22** | +$15,425.46 | 693 | $22.26 | 7.47% |
| **3** | **`Setup 1` + `Setup 2 Nac`** | **1.20** | +$21,128.91 | 921 | $22.94 | 8.03% |
| **2** | **Solo `Setup 2 Nacimiento`** | **1.18** | +$4,911.93 | 228 | $21.54 | 4.44% |
| **0** | Ninguno activo | 0.00 | $0.00 | 0 | $0.00 | 0.00% |

### Lectura por Motor Operativo
* **Todos los motores individuales son rentables:** A diferencia de iteraciones previas, en `v3` cada motor por separado cierra con PF sólido (`1.49` en S2 Continuación, `1.22` en S1 y `1.18` en S2 Nacimiento).
* **Mayor eficiencia riesgo/retorno:** El **Paso 4 (`Solo S2 Continuación`)** logra un PF de `1.49` con apenas `3.37%` de drawdown, mientras que el **Paso 6 (`S2 Nac + S2 Cont`)** ofrece el mejor equilibrio multisetup (`PF 1.28`, `DD 5.16%`).
* **Máxima capitalización:** El **Paso 7 (`Todos activos`)** escala el beneficio neto a `+$27,999.87` (en optimización) / `+$30,671.66` (en backtest 99%) manteniendo el drawdown por debajo del umbral del `8%`.

---

## 3. Estadísticas Detalladas del Backtest (Calidad 99%)

* **Entorno de Simulación:** `NAS100`, `M5` | Calidad de historial: `99%` (`275,862` barras / `185,005,859` ticks).
* **Capital y Retorno:** Depósito inicial `100,000.00` $\rightarrow$ Balance final `130,671.66` (`+30.67%`).
* **Beneficio Bruto vs. Pérdida Bruta:** `+$145,472.64` vs. `-$114,800.98`.
* **Control de Drawdown:**
  * Balance Máximo: `9,489.68` (`7.50%`) | Balance Absoluto: `1,685.47`
  * Equidad Máxima: `10,020.00` (`7.90%`) | Equidad Absoluta: `1,816.03`
* **Calidad Estadística:**
  * **LR Correlation:** `0.90` (curva altamente lineal) | **LR Standard Error:** `3,445.82`
  * **Z-Score:** `0.85` (`60.47%`) | **AHPR / GHPR:** `1.0003` (`0.03%`)
* **Distribución de Operaciones:**
  * **Total Operaciones:** `1,010` (`2,020` transacciones)
  * **Posiciones Largas:** `572` (`46.85%` ganadoras) | **Posiciones Cortas:** `438` (`41.78%` ganadoras)
  * **Win Rate Global:** `44.65%` (`451` ganadoras / `559` perdedoras)
  * **Ratio Riesgo/Beneficio Real:** Ganancia media `+$322.56` vs. Pérdida media `-$205.37` (**Ratio `1.57 : 1`**).
  * **Extremos:** Mayor ganancia `+$2,444.17` | Mayor pérdida `-$647.66`.
  * **Rachas:** Máx. ganancias seguidas `7` (`+$1,276.19`, pico monetario `+$4,025.75` en `5` trades) | Máx. pérdidas seguidas `9` (`-$1,845.81`).

---

## 4. Análisis Temporal y Comportamiento de la Curva

### Estacionalidad y Horarios
* **Consistencia Mensual (100% positivo):** **Los 12 meses del año cierran en ganancia neta**, destacando julio, agosto y junio por margen neto, y abril/octubre por volumen operativo (`~105-108` trades).
* **Consistencia Semanal (5 de 5 días positivos):** Lunes a viernes cierran todos en positivo neto, liderados ampliamente por el **jueves** (`~$39,000` brutos vs. `~$21,500` en pérdidas).
* **Franja Horaria (Servidor):** Actividad concentrada entre `14:00` y `22:00` (pico a las `17:00` con `~290` entradas). A diferencia de versiones anteriores, la ventana de las `18:00` a `22:00` aporta un margen neto muy favorable.
* **Correlación MFE / MAE:** `Profits vs. MFE = 0.86` (excelente captura de recorrido a favor) | `Profits vs. MAE = 0.60` | `MFE vs. MAE = 0.3424`.

### Cronología de la Curva de Equidad (`2023.01.11` – `2026.10.12`)
1. **H1 2023:** Impulso inicial rápido de `100,000` a `~110,000` USD (`+10%`).
2. **H2 2023 – Q1 2024:** Consolidación lateral controlada entre `108,500` y `113,200` USD.
3. **Q2 2024 – Q1 2025:** Expansión fuerte en dos ondas hasta alcanzar un máximo local de `~126,500` USD.
4. **Q2 – Q4 2025:** Fase de ajuste/drawdown más prolongada del histórico hasta la zona de `116,800` USD (`7.90%` DD máximo sobre equidad).
5. **2026:** Recuperación sostenida en H1 y aceleración alcista marcada en Q3–Q4, marcando nuevos máximos históricos sobre `131,019` USD (cierre en `130,671.66` USD).
* **Apalancamiento y Flotante:** La equidad (verde) sigue estrechamente al balance (azul) con picos flotantes a favor y una **carga de depósito inferior al `1.0%`** durante toda la serie.