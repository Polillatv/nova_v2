# CHANGELOG

## v3.13 - Nova_Bot_v3.mq5 (Edición Híbrida Unificada)
Unificación de los hallazgos empíricos de `v3.10`, `v3.11` y `v3.12` en un único EA productivo (`MAGIC 2026xx`):
- **Trailing desacoplado por tipo de motor:**
  - `InpTrailModeQe = TRAIL_ATR_SWING` para **Setup 1 y Setup 2 Continuación** (captura la mejora de `v3.11` en `Pass 5`: `+$24,404`, `PF 1.29`, `DD 6.69%`, y `Solo S2C` `PF 1.55`).
  - `InpTrailModeS2N = TRAIL_NOVA_SWING` para **Setup 2 Nacimiento** (conserva el margen holgado de `v3.10` en `Pass 2`: `+$4,912`, `PF 1.18`, evitando que los escalones `1.20/1.50R` saquen la operación durante el retesteo del borde `100% FINAL` del rango).
- **Corrección del respaldo ATR (`InpTrailX_ATROnlyWithoutSwing = true`, `InpTrailX_ATROnBarClose = true`):**
  - El ATR ahora actúa **únicamente como respaldo en impulsos verticales** mientras aún no exista un swing fractal M5 confirmado por encima del piso (`!haySwingSobrePiso`). En cuanto el precio forma estructura fractal M5 real, el trailing pasa exclusivamente a swings para permitir runners completos de `4R–5R` (eliminando el techo artificial de `~$1,540` observado en `v3.11` y `v3.12`).
  - Evaluación de `ATR(14)` cacheada una vez por cierre de barra M5 (`ObtenerATRYCierreM5`), evitando barridas por mechas intrabar de un tick y acelerando el backtesting.
- **Limpieza de repositorio:** `Nova_Bot_v3_1.mq5` y `Nova_Bot_v3_2.mq5` se archivan en `archive/` (sin `.ex5`) dejando a `Nova_Bot_v3` como único EA activo.

## v3.12 - archive/Nova_Bot_v3_2.mq5
Variante de `v3.11` tras el backtest (`v3.11`: `+27.70%` PF `1.24` vs `v3.10`: `+30.67%` PF `1.27`):
- `InpTrailX_ATRMult` `2.0` -> `3.0`, `InpTrailX_ATRStartRR` `1.5` -> `2.0`, `InpTrailX_SwingStartRR` `1.5` -> `2.0`.
- Escalones `1.20 / 1.50 / 1.80R` mantenidos globalmente.
- Resultado `2023–2026`: `+26.49%`, PF `1.23`, DD eq `7.72%` (menor DD de las tres corridas previas, pero menor retorno neto porque `atrSL` intrabar seguía pisando al `swingSL` en `~3R` y los escalones extra seguían penalizando a `S2N`).

## v3.11 - archive/Nova_Bot_v3_1.mq5
Experimento de trailing activo (`TRAIL_ATR_SWING` global):
- Escalones: `+0.50R -> -0.25R`, `+0.80R -> +0.50R`, `+1.20R -> +0.70R`, `+1.50R -> +1.00R`, `+1.80R -> +1.30R`.
- Swing fractal M5 y piso `2.0 x ATR(14)` desde `+1.50R` evaluado tick a tick en todos los setups.
- Resultado `2023–2026`: `+27.70%`, PF `1.24`, Sharpe `3.92`. Mejoró notablemente `S1 + S2C` (`+$24,404`, `PF 1.29`, `DD 6.69%`), pero penalizó `S2 Nacimiento` (`PF 1.05`) y limitó el mejor trade a `+$1,528`.

## v3.10 - Nova_Bot_v3.mq5 (Base Calibrada)
Calibración fiel al backtest manual (`S2C` invalida `S1`, orden Stop directa en `2Qe`, observación `08:00 NY`, `Setup 3` con cuerpo + cruce `50%`, Hora de Gracia única a los `60m`, escalón `+1.80R -> +1.15R` y swings desde `+2.00R`). Resultado `2023–2026`: `+30.67%`, PF `1.27`, DD eq `7.90%`.
