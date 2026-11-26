# Reporte de Backtest - MetaTrader 5 Strategy Tester

## 1. Configuración General del Test
- **Broker / Servidor:** Pepperstone Group Limited (`61642022 - Pepperstone-Demo: Demo Account - Hedge`)
- **Activo y Temporalidad:** `NAS100` | `M5`
- **Período Analizado:** `2023.01.03` a `2023.06.26` (Enero - Junio 2023)
- **Calidad del Historial (`History Quality`):** `100%`
- **Barras (`Bars`):** `35,016`
- **Ticks:** `22,806,465`
- **Símbolos (`Symbols`):** `1`
- **Depósito Inicial (`Initial Deposit`):** `$100,000.00`

---

## 2. Métricas de Rendimiento y Riesgo

### Resultados Financieros
- **Beneficio Neto Total (`Total Net Profit`):** `$9,087.37` (`+9.09%` sobre depósito inicial)
- **Beneficio Bruto (`Gross Profit`):** `$29,705.41`
- **Pérdida Bruta (`Gross Loss`):** `-$20,618.04`
- **Factor de Beneficio (`Profit Factor`):** `1.44`
- **Factor de Recuperación (`Recovery Factor`):** `2.03`
- **Beneficio Esperado (`Expected Payoff`):** `$50.49`
- **Ratio de Sharpe (`Sharpe Ratio`):** `6.64`
- **AHPR:** `1.0005` (`0.05%`)
- **GHPR:** `1.0005` (`0.05%`)

### Drawdown (Reducción)
- **Balance Drawdown Absoluto:** `$1,803.18`
- **Balance Drawdown Máximo:** `$3,985.42` (`3.70%`)
- **Balance Drawdown Relativo:** `3.70%` (`$3,985.42`)
- **Equity Drawdown Absoluto:** `$1,977.53`
- **Equity Drawdown Máximo:** `$4,465.78` (`4.13%`)
- **Equity Drawdown Relativo:** `4.13%` (`$4,465.78`)

### Estadísticas de Regresión y Margen
- **Correlación LR (`LR Correlation`):** `0.88`
- **Error Estándar LR (`LR Standard Error`):** `$1,523.45`
- **Nivel de Margen (`Margin Level`):** `6689.18%`
- **Z-Score:** `-2.46` (`98.61%`)

---

## 3. Estadísticas de Operaciones (`Trades` y `Deals`)
- **Total de Operaciones (`Total Trades`):** `180` (`360` deals)
- **Operaciones Cortas (`Short Trades`):** `70` (`47.14%` ganadas)
- **Operaciones Largas (`Long Trades`):** `110` (`53.64%` ganadas)
- **Operaciones Rentables (`Profit Trades`):** `92` (`51.11%` del total)
- **Operaciones con Pérdida (`Loss Trades`):** `88` (`48.89%` del total)

### Promedios, Extremos y Rachas
- **Mayor operación ganadora (`Largest profit trade`):** `$1,999.81`
- **Mayor operación perdedora (`Largest loss trade`):** `-$548.00`
- **Promedio operación ganadora (`Average profit trade`):** `$322.88`
- **Promedio operación perdedora (`Average loss trade`):** `-$234.30`
- **Máximas ganancias consecutivas (`Maximum consecutive wins`):** `13` (`$6,141.35`)
- **Máximas pérdidas consecutivas (`Maximum consecutive losses`):** `7` (`-$371.15`)
- **Máximo beneficio consecutivo (`Maximal consecutive profit`):** `$6,141.35` (`13` trades)
- **Máxima pérdida consecutiva (`Maximal consecutive loss`):** `-$1,889.82` (`6` trades)
- **Promedio de ganancias consecutivas:** `2`
- **Promedio de pérdidas consecutivas:** `2`

---

## 4. Correlaciones (MAE / MFE)
- **Correlación (`Profits, MFE`):** `0.85` (Alta correlación positiva entre excursión máxima favorable y beneficio final)
- **Correlación (`Profits, MAE`):** `0.52`
- **Correlación (`MFE, MAE`):** `0.2180`

---

## 5. Análisis de Distribución Temporal y Curva de Capital

### Evolución de la Curva de Balance y Equity (`Graph`)
- **Enero 2023:** Retroceso inicial hasta el mínimo del período cerca de `$98,050` alrededor del `2023.01.16`, seguido de recuperación hacia `$100,700` a fin de mes.
- **Febrero 2023:** Consolidación lateral con ligero avance hasta `~$101,400` - `$102,700` hacia el `2023.02.22`.
- **Marzo - Abril 2023:** Fuerte impulso alcista entre finales de marzo (`2023.03.28`) y abril (`2023.04.24`), escalando de `~$103,400` hasta superar los `$108,000`.
- **Mayo 2023:** Fase de retroceso controlado y consolidación bajista desde `~$107,400` hacia `~$104,000`.
- **Junio 2023:** Segundo gran tramo impulsivo a partir del `2023.06.08`, alcanzando el pico máximo de equidad cerca de `$110,746` el `2023.06.15` y cerrando el semestre alrededor de `$109,087`.
- **Carga de Depósito (`Deposit Load`):** Muy baja y constante en todo el período (por debajo del `2%` en los picos visibles, escala máxima del panel `10.0%`).

### Distribución de Entradas y Resultados (Histogramas)
- **Por Hora (Horario Servidor MT5):**
  - Las entradas se concentran exclusivamente entre las `15:00` y `21:00` horas del servidor, con el pico máximo de frecuencia a las `17:00` (`~53` entradas), seguido de `18:00` (`~35`) y `16:00` (`~31`).
  - La mayor rentabilidad neta se concentra en las horas `18:00` (`~$7,300` brutos) y `22:00` (cierres/gestión), mientras que a las `17:00` el volumen de pérdidas es mayor.
- **Por Día de la Semana:**
  - **Domingo (`Sun`) y Sábado (`Sat`):** `0` entradas ejecutadas (el EA no está operando los domingos en este test).
  - **Lunes (`Mon`):** `~27` entradas; beneficio bruto superior a pérdida bruta (`~$4,900` vs `~$3,000`).
  - **Martes (`Tue`):** `~35` entradas; mejor día de la semana en relación ganancia/pérdida (`~$8,900` ganancia vs `~$3,600` pérdida).
  - **Miércoles (`Wed`):** `~38` entradas; ligeramente negativo (`~$5,000` ganancia vs `~$5,400` pérdida).
  - **Jueves (`Thu`):** `41` entradas (día más activo); segundo mejor día (`~$8,300` ganancia vs `~$4,000` pérdida).
  - **Viernes (`Fri`):** `~36` entradas; día negativo en el acumulado (`~$3,000` ganancia vs `~$5,400` pérdida).
- **Por Mes (Ene - Jun 2023):**
  - **Meses positivos:** Enero (`~$3,700` vs `~$3,400`), Febrero (`~$4,900` vs `~$4,100`), Marzo (`~$5,300` vs `~$3,200`), Abril (`~$5,800` vs `~$1,600` - mejor ratio mensual), y Junio (`~$8,300` vs `~$3,800` - mayor ganancia bruta).
  - **Mes negativo:** Mayo (`~$2,400` ganancia bruta vs `~$5,800` pérdida bruta), coincidiendo con el drawdown observado en la curva de balance.

---

## 6. Reconciliación con las Capturas Adjuntas en esta Carpeta
Esta carpeta contiene capturas de **dos corridas adicionales** realizadas el `2026-11-24` que difieren de la corrida de `$9,087.37` documentada arriba:

1. **Corrida 18:16 (`Captura de pantalla 2026-11-24 181601.png` y `181653.png`):**
   - `Total Net Profit`: `$322.71` | `Profit Factor`: `1.02` | `Trades`: `194` (`55.67%` winrate) | `Equity DD Máx`: `3.60%` (`$3,639.50`).
2. **Corrida 19:13 (`Captura de pantalla 2026-11-24 191341.png` y `191353.png`):**
   - `Total Net Profit`: `-$4,867.67` | `Profit Factor`: `0.88` | `Trades`: `99` (`17.17%` winrate) | `Equity DD Máx`: `14.21%` (`$14,698.46`).
   - Coincide con la configuración de ablación en `archive/Nova_Bot_v1.mq5` (`v3.11`) con las salidas (`InpExit_Grace`, `InpExit_Open930`, `InpExit_S2N_BE`, `InpExit_Trailing`, `InpExit_EndOfDay`) desactivadas (`false`), dejando TP/SL fijos (`4R/5R`).
