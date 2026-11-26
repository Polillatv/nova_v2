# CHANGELOG

## v3.12 - Nova_Bot_v3_2.mq5
Variante de v3.11 tras el backtest (v3.11: +27.70% PF 1.24 vs v3.10: +30.67% PF 1.27; el trailing cortaba trades ganadores):
- `InpTrailX_ATRMult` 2.0 -> **3.0**, `InpTrailX_ATRStartRR` 1.5 -> **2.0**, `InpTrailX_SwingStartRR` 1.5 -> **2.0**.
- Escalones 1.20/1.50/1.80R se mantienen.
- Magics 2046xx, claves `NOVA32_`, trace `Nova_v3_2_trace_*.csv`.
- Resultado 2023-2026: +26.49%, PF 1.23, DD eq 7.72% (peor que v3.10 +30.67% y v3.11 +27.70%). Sospecha: los escalones extra 1.2-1.8R.

## v3.11 - Nova_Bot_v3_1.mq5
Mejora de trailing (el v3.10 deja el SL muy atras en impulsos verticales):
- Nuevo modo `TRAIL_ATR_SWING` (default en este archivo). Los modos `NOVA_SWING` y `OPTIMIZED` siguen disponibles.
- Escalones: +0.50R -> -0.25R, +0.80R -> +0.50R, **+1.20R -> +0.70R, +1.50R -> +1.00R, +1.80R -> +1.30R**.
- Swing fractal M5 desde **+1.5R** (antes 2.0R): `InpTrailX_SwingStartRR`.
- **Piso ATR(M5)** desde +1.5R: SL = precio -/+ `InpTrailX_ATRMult` x ATR (2.0 por defecto); se usa el mas cercano al precio entre escalon, swing y ATR. El SL nunca retrocede.
- Magics 2036xx y claves `NOVA31_` / trace `Nova_v3_1_trace_*.csv` para convivir con v3.10.
- Pendiente: validar en Strategy Tester vs v3.10 (mismo periodo, ticks reales) y ajustar `ATRMult`.

## v3.10 - Nova_Bot_v3.mq5
Calibracion fiel al backtest manual (ver `PLAN_IMPLEMENTACION.txt`).