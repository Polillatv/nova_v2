# CHANGELOG

> **Convención de versiones:** La numeración oficial sigue siempre el `#property version` compilado en el EA (`v3.10`, `v3.11`, `v3.12`, `v3.13`, `v3.14`).

## v3.14 - Nova_Bot_v3.mq5 (Edición Fiel Manual — Corrección de Bugs de Traza H1 2023)
Iteración derivada de la auditoría vela a vela (`Nova_v3_trace_2023_H1.csv` vs `backtest_2023_h1.md`) y alineada con la gestión manual real:
- **Fix Bug #1 (`1QR != 1Qe` en la misma barra):** `EvaluarVela()` ya no ejecuta `ProcesarMotorQeVela()` ni `ProcesarSetup2NacimientoVela()` en la misma vela que acaba de activar `1QR` o `2QR`. Elimina el auto-conteo prematuro de `1Qe` sobre la vela de ruptura inicial y exige los **2 quiebres estructurales reales (`1Qe` + `2Qe`)** en `Setup 1` y `Setup 2 Continuación`.
- **Fix Bug #2 (Aislamiento 24/7 de posiciones nocturnas sin `07:00 FILL` fantasma):** Las posiciones abiertas tras `15:45 NY` (`InpClose1540Rule = false`) se capturan en `g_CarryPos[]` al cambio de día (`00:00 NY`) y se monitorean 24/7 (incluso entre `00:00` y `07:00 NY`) sin consumir el cupo `tradesToday` ni bloquear las nuevas señales de la jornada siguiente, asegurando además `BE+` (`+0.05R`) al cierre de Asia (`21:30 NY` / pre-cierre viernes).
- **Mitigación de SL a los 60 minutos (`InpGraceCloseMarket = false`):** Reemplaza el cierre forzoso a mercado de los 60 minutos (que cortaba `39.4%` de las operaciones en `v3.13`) por el ajuste de mitigación del SL a **`-0.25R`** (o micro-swing M5 post-entrada si el precio está temporalmente más profundo, fijando `-0.25R` apenas recupera margen).
- **Nuevo motor `TRAIL_M5_SWING` por defecto (`InpTrailModeQe` y `InpTrailModeS2N`):** Elimina el escalón rígido `+0.80R -> +0.50R` y mueve el SL por encima de `-0.25R` únicamente sobre **swings estructurales M5 formados después de la entrada** (exigiendo confirmación `BOS` antes de `+2.0R`, todo fractal M5 desde `>= +2.0R`, y respaldo `ATR` al cierre M5 solo en impulsos verticales `>= +2.0R` sin swings sobre `BE`).

## v3.13 - archive/Nova_Bot_v3_13.mq5 (Edición Híbrida Desacoplada)
Unificación de los mejores componentes empíricos en un único EA productivo (`MAGIC 2026xx`), validada en `backtests/mt5_v3_13/`:
- **Trailing desacoplado por tipo de motor:**
  - `InpTrailModeQe = TRAIL_ATR_SWING` para **Setup 1 y Setup 2 Continuación**.
  - `InpTrailModeS2N = TRAIL_NOVA_SWING` para **Setup 2 Nacimiento** (recupera el `100%` de rendimiento de `S2N`: `+$4,911.93`, `PF 1.18`, `DD 4.44%`).
- **Respaldo ATR inteligente (`InpTrailX_ATROnlyWithoutSwing = true`, `InpTrailX_ATROnBarClose = true`):**
  - `ATR(14)` evaluado al cierre de barra M5 únicamente cuando aún no existe un swing fractal M5 confirmado por encima del piso; libera nuevamente los runners completos de `5R` (`+$2,444.17`).
- **Resultado validado `2023–2026` (`185M` ticks):**
  - Backtest `99%`: **`+$30,198.83` (`+30.20%`)**, **`PF 1.26`**, **récord de menor Drawdown (`7.18%` equidad / `6.78%` balance)**, **Sharpe `4.01`**, **Recovery Factor `3.29`** y **LR Correlation `0.92`**.
  - Optimización (`Pass 7` Todos): **récord de ganancia (`+$28,549.46`)** con **`7.03%` DD**, superando a `v3.10` en los 7 pases de setups.

## v3.12 - archive/Nova_Bot_v3_12.mq5
Experimento sobre `v3.11` (`backtests/mt5_v3_12/`):
- `InpTrailX_ATRMult` `2.0` -> `3.0`, `InpTrailX_ATRStartRR` `1.5` -> `2.0`, `InpTrailX_SwingStartRR` `1.5` -> `2.0`; escalones `1.20 / 1.50 / 1.80R` mantenidos globalmente.
- Resultado `2023–2026`: `+26.49%`, `PF 1.23`, `DD eq 7.72%`, mejor trade topado en `+$1,542.01`.

## v3.11 - archive/Nova_Bot_v3_11.mq5
Experimento de trailing activo `TRAIL_ATR_SWING` global (`backtests/mt5_v3_11/`):
- Escalones `1.20 / 1.50 / 1.80R` + swing fractal y piso `2.0 x ATR(14)` tick a tick desde `+1.50R` en todos los setups.
- Resultado `2023–2026`: `+27.70%`, `PF 1.24`, `Sharpe 3.92`. Mejoró `S1 + S2C` (`+$24,404`, `PF 1.29`, `DD 6.69%`), pero penalizó `S2 Nacimiento` (`PF 1.05`) y limitó el mejor trade a `+$1,528.17`.

## v3.10 - Base Calibrada (`backtests/mt5_v3_10/`)
Calibración fiel al backtest manual (`S2C` invalida `S1`, orden Stop directa en `2Qe`, observación `08:00 NY`, `Setup 3` con cuerpo + cruce `50%`, Hora de Gracia única a los `60m`, escalón `+1.80R -> +1.15R` y swings desde `+2.00R`). Resultado `2023–2026`: `+30.67%`, `PF 1.27`, `DD eq 7.90%`.
