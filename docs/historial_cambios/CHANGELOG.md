# CHANGELOG

> **Convención de versiones:** La numeración oficial sigue siempre el `#property version` compilado en el EA (`v3.10`, `v3.11`, `v3.12`, `v3.13`). La rama principal `main` mantiene **`v3.13`** en `Nova_Bot_v3.mq5` como versión productiva activa.

---

## v3.13 — `Nova_Bot_v3.mq5` (**Versión Principal Productiva Actual**)
Unificación de los mejores componentes empíricos en un único EA productivo (`MAGIC 2026xx`), validada en `backtests/mt5_v3_13/`:
- **Trailing desacoplado por tipo de motor:**
  - `InpTrailModeQe = TRAIL_ATR_SWING` para **Setup 1 y Setup 2 Continuación**.
  - `InpTrailModeS2N = TRAIL_NOVA_SWING` para **Setup 2 Nacimiento** (recupera el `100%` de rendimiento de `S2N`: `+$4,911.93`, `PF 1.18`, `DD 4.44%`).
- **Respaldo ATR inteligente (`InpTrailX_ATROnlyWithoutSwing = true`, `InpTrailX_ATROnBarClose = true`):**
  - `ATR(14)` evaluado al cierre de barra M5 únicamente cuando aún no existe un swing fractal M5 confirmado por encima del piso; libera nuevamente los runners completos de `5R` (`+$2,444.17`).
- **Resultado validado `2023–2026` (`185M` ticks):**
  - Backtest `99%`: **`+$30,198.83` (`+30.20%`)**, **`PF 1.26`**, **récord de menor Drawdown (`7.18%` equidad / `6.78%` balance)**, **Sharpe `4.01`**, **Recovery Factor `3.29`** y **LR Correlation `0.92`**.
  - Optimización (`Pass 7` Todos): **récord de ganancia (`+$28,549.46`)** con **`7.03%` DD**, superando a `v3.10` en los 7 pases de setups.

---

## Versiones Previas de la Serie Productiva (`archive/`)

### v3.12 — `archive/Nova_Bot_v3_12.mq5`
Experimento sobre `v3.11` (`backtests/mt5_v3_12/`):
- `InpTrailX_ATRMult` `2.0` -> `3.0`, `InpTrailX_ATRStartRR` `1.5` -> `2.0`, `InpTrailX_SwingStartRR` `1.5` -> `2.0`; escalones `1.20 / 1.50 / 1.80R` mantenidos globalmente.
- Resultado `2023–2026`: `+26.49%`, `PF 1.23`, `DD eq 7.72%`, mejor trade topado en `+$1,542.01`.

### v3.11 — `archive/Nova_Bot_v3_11.mq5`
Experimento de trailing activo `TRAIL_ATR_SWING` global (`backtests/mt5_v3_11/`):
- Escalones `1.20 / 1.50 / 1.80R` + swing fractal y piso `2.0 x ATR(14)` tick a tick desde `+1.50R` en todos los setups.
- Resultado `2023–2026`: `+27.70%`, `PF 1.24`, `Sharpe 3.92`. Mejoró `S1 + S2C` (`+$24,404`, `PF 1.29`, `DD 6.69%`), pero penalizó `S2 Nacimiento` (`PF 1.05`) y limitó el mejor trade a `+$1,528.17`.

### v3.10 — `archive/Nova_Bot_v3_10.mq5`
Calibración base (`backtests/mt5_v3_10/`): `S2C` invalida `S1`, orden Stop directa en `2Qe`, observación `08:00 NY`, `Setup 3` con cuerpo + cruce `50%`, Hora de Gracia única a los `60m`, escalón `+1.80R -> +1.15R` y swings desde `+2.00R`. Resultado `2023–2026`: `+30.67%`, `PF 1.27`, `DD eq 7.90%`.

---

## Experimentos Descartados (`archive/` — NO usar en producción)

### v3.15 — `archive/Nova_Bot_v3_15.mq5` *(Descartada — ver `backtests/mt5_v3_15/reporte_trace_v3_15.md`)*
- Intentó parchar `v3.14` quitando el micro-swing a los `60m` (`InpGraceMicroSwing = false`), liberando fractales sin `BOS` desde `+1.0R` y añadiendo piso `+1.25R -> +0.60R`.
- Resultado `2023–2026`: **`+22.34R` (`+11.17%`)**, `PF 1.12`, `WR 35.0%`, con pérdida neta de `-14.55R` en `2025–2026` por disparo de stops completos (`94` `INIT_SL` = `-94.16R`) y corte prematuro de continuaciones.

### v3.14 — `archive/Nova_Bot_v3_14.mq5` *(Descartada — ver `backtests/mt5_v3_14/reporte_trace_v3_14_asia.md`)*
- Sustituyó el cierre por hora de gracia y `15:40 NY` por carryover 24/7 + mitigación `-0.25R` y `TRAIL_M5_SWING`.
- Resultado `2023–2026` (con Asia ON): **`+31.14R` (`+16.18%`)**, `PF 1.14`, estancándose en `2025–2026` (`-1.06R`) frente al `+60.4R` (`PF 1.26`) de `v3.13`.
