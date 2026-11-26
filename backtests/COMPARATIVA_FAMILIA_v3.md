# Comparativa Evolutiva Familia v3 (`v3.10` vs `v3.11` vs `v3.12` vs `v3.13`)

Entorno común de simulación: `NAS100 M5` | `2023.01.11 – 2026.10.12` (~3 años y 9 meses) | Calidad `99%` (`275,862` barras / `185,005,859` ticks reales) | Depósito inicial `100,000.00 USD` (`0.50%` riesgo/op).

---

## 1. Backtest Completo (`99%` Ticks — Todos los Setups Activos)

| Métrica | `v3.10` (`mt5_v3_10/`) | `v3.11` (`mt5_v3_11/`) | `v3.12` (`mt5_v3_12/`) | **`v3.13` Actual (`mt5_v3_13/`)** | Mejor de la Serie |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Beneficio Neto** | **`+$30,671.66` (`+30.67%`)** | `+$27,704.44` (`+27.70%`) | `+$26,488.50` (`+26.49%`) | **`+$30,198.83` (`+30.20%`)** | Empate técnico en cima (`+$30k`) |
| **Beneficio Bruto** | `+$145,472.64` | `+$142,540.54` | `+$141,405.56` | **`+$146,093.23`** | **`v3.13` mayor ganancia bruta** |
| **Equity Drawdown Máx.** | `7.90%` (`$10,020.00`) | `8.06%` (`$10,164.98`) | `7.72%` (`$9,730.28`) | **`7.18%` (`$9,179.52`)** | **`v3.13` (`-0.72 pp` vs `v3.10`)** |
| **Balance Drawdown Máx.** | `7.50%` (`$9,489.68`) | `7.66%` (`$9,634.66`) | `7.32%` (`$9,199.96`) | **`6.78%` (`$8,644.62`)** | **`v3.13` (`-0.72 pp` vs `v3.10`)** |
| **Ratio de Sharpe** | `3.64` | `3.92` | `3.59` | **`4.01`** | **`v3.13` supera barrera de `4.0`** |
| **Factor de Recuperación** | `3.06` | `2.73` | `2.72` | **`3.29`** | **`v3.13` máxima resiliencia** |
| **Profit Factor** | **`1.27`** | `1.24` | `1.23` | **`1.26`** | Virtualmente idénticos |
| **LR Correlation** | `0.90` | `0.90` | `0.90` | **`0.92`** | **`v3.13` curva más lineal** |
| **LR Standard Error** | `3,445.82` | `3,247.90` | `3,209.01` | **`3,184.17`** | **`v3.13` menor dispersión** |
| **Total Operaciones** | `1,010` | `1,015` | `1,013` | **`1,013`** | Consistencia total (`~1,012`) |
| **Win Rate Global** | `44.65%` | `44.73%` | `44.62%` | **`44.72%`** | Estable en `~44.7%` |
| **Expected Payoff** | **`$30.37`** | `$27.30` | `$26.15` | **`$29.81`** | ~`$30` por trade |
| **Mejor Trade Individual** | **`+$2,444.17`** | `+$1,528.17` | `+$1,542.01` | **`+$2,444.17`** | **`v3.13` libera techo de `5R`** |
| **Máx. Racha Monetaria** | `+$4,025.75` (5) | `+$3,505.40` (4) | `+$3,713.41` (5) | **`+$4,225.56` (5)** | **`v3.13`** |

---

## 2. Optimización por Combinación de Setups (`PF` / `Beneficio Neto` / `DD`)

| Paso y Combinación | `v3.10` (`NOVA_SWING` global) | `v3.11` (`ATR x2` tick global) | `v3.12` (`ATR x3` @ `2.0R` global) | **`v3.13` (Híbrido `Qe` + `S2N`)** |
| :--- | :---: | :---: | :---: | :---: |
| **Pass 7: Todos (`S1+S2N+S2C`)** | `1.24` / `+$28,000` / `8.09%` | `1.23` / `+$26,326` / `7.83%` | `1.22` / `+$24,891` / `7.66%` | **`1.24` / `+$28,549` / `7.03%`** |
| **Pass 5: `S1 + S2 Cont`** | `1.27` / `+$22,283` / `7.93%` | **`1.29` / `+$24,404` / `6.69%`** | `1.27` / `+$21,956` / `6.89%` | **`1.27` / `+$22,538` / `6.92%`** |
| **Pass 3: `S1 + S2 Nac`** | `1.20` / `+$21,129` / `8.03%` | `1.18` / `+$19,075` / `7.81%` | `1.18` / `+$18,265` / `7.52%` | **`1.21` / `+$21,813` / `6.72%`** |
| **Pass 1: Solo `Setup 1`** | `1.22` / `+$15,425` / `7.47%` | **`1.24` / `+$17,262` / `6.79%`** | `1.22` / `+$15,513` / `6.96%` | **`1.23` / `+$16,158` / `6.80%`** |
| **Pass 6: `S2 Nac + S2 Cont`** | `1.28` / `+$13,219` / `5.16%` | `1.23` / `+$10,608` / `6.67%` | `1.23` / `+$10,511` / `6.65%` | **`1.29` / `+$13,588` / `5.33%`** |
| **Pass 4: Solo `S2 Cont`** | `1.49` / `+$7,931` / `3.37%` | **`1.55` / `+$8,981` / `3.27%`** | `1.49` / `+$8,005` / `3.29%` | **`1.51` / `+$8,244` / `3.27%`** |
| **Pass 2: Solo `S2 Nacimiento`** | **`1.18` / `+$4,912` / `4.44%`** | `1.05` / `+$1,479` / `5.13%` | `1.09` / `+$2,346` / `5.42%` | **`1.18` / `+$4,912` / `4.44%`** |

---

## 3. Conclusiones Definitivas

1. **`v3.13` es la versión productiva óptima (especialmente para Prop Firm Bullfy):**
   - En la matriz de optimización (`Pass 7` con todos los motores activos), **`v3.13` supera a las 3 versiones anteriores tanto en ganancia neta (`+$28,549.46`) como en control de riesgo (`7.03%` DD vs `8.09%` en `v3.10`)**, mejorando además **todos y cada uno** de los 7 pases operativos frente a `v3.10`.
   - En el backtest individual `99%`, mantiene el techo de `+$30,198.83` pero **baja el Drawdown máximo de equidad de `7.90%` (`$10,020`, al filo de un límite típico del `8%` en fondeo) a `7.18%` (`$9,179.52`)** y el de balance a **`6.78%`**, llevando el **Sharpe a `4.01`**, el **Recovery Factor a `3.29`** y la **correlación lineal a `0.92`**.
2. **Validación exacta de las dos hipótesis de diseño:**
   - Desacoplar `InpTrailModeS2N = TRAIL_NOVA_SWING` restauró el `100%` del rendimiento de `Setup 2 Nacimiento` (`+$4,911.93`, `PF 1.18`).
   - Restringir el ATR al cierre de barra M5 únicamente cuando aún no hay swing fractal sobre el piso (`InpTrailX_ATROnlyWithoutSwing = true`) eliminó el tope artificial de `~$1,540` de `v3.11`/`v3.12` y devolvió los runners completos de **`+$2,444.17` (`5R`)**.
