# Comparativa de backtests: Nova_Bot_v3 (v3.10) vs Nova_Bot_v3_1 (v3.11)

NAS100 M5, 2023.01 - 2026.10, calidad 99%, depósito 100,000. Fuente: `mt5_v3_historico/` y `mt5_v3_1_historico/`.

## Backtest completo (todos los setups activos)

| Métrica | v3.10 | v3.11 | Diferencia |
|---|---:|---:|---:|
| Beneficio neto | +30,671.66 (+30.67%) | +27,704.44 (+27.70%) | -2,967 |
| Profit Factor | 1.27 | 1.24 | -0.03 |
| Factor de recuperación | 3.06 | 2.73 | -0.33 |
| Beneficio esperado | 30.37 | 27.30 | -3.07 |
| DD balance máx. | 7.50% | 7.66% | +0.16 pp |
| DD equidad máx. | 7.90% | 8.06% | +0.16 pp |
| Sharpe | 3.64 | 3.92 | +0.28 |
| Operaciones | 1,010 | 1,015 | +5 |
| Ganancia media | 322.56 | 313.97 | -8.59 |
| Pérdida media | -205.37 | -204.70 | +0.67 |
| Mejor trade | 2,444.17 | 1,528.17 | -916 |
| Peor trade | -647.66 | -630.63 | +17 |

## Optimización por setups (PF / beneficio / DD)

| Combinación | v3.10 | v3.11 |
|---|---|---|
| Solo S2 Cont | 1.49 / 7,931 / 3.37% | 1.55 / 8,981 / 3.27% |
| S1 + S2 Cont | 1.27 / 22,283 / 7.93% | 1.29 / 24,404 / 6.69% |
| S2 Nac + S2 Cont | 1.28 / 13,219 / 5.16% | 1.23 / 10,608 / 6.67% |
| Solo S1 | 1.22 / 15,425 / 7.47% | 1.24 / 17,262 / 6.79% |
| S1 + S2 Nac | 1.20 / 21,129 / 8.03% | 1.18 / 19,075 / 7.81% |
| Solo S2 Nac | 1.18 / 4,912 / 4.44% | 1.05 / 1,479 / 5.13% |
| Todos | 1.24 / 27,999 / 8.09% | 1.23 / 26,326 / 7.83% |

## Lectura
- El trailing nuevo **no mejora el resultado global**: -3 pp de retorno, PF 1.27 -> 1.24 y el mejor trade baja de 2,444 a 1,528. El piso ATR y el swing temprano cortan los trades que corrían hasta el TP.
- Sí ayuda en **S1 y S1 + S2 Cont** (mejor PF, retorno y DD) y en **S2 Cont sola**. Perjudica a **S2 Nacimiento** (PF 1.18 -> 1.05).
- Hipótesis: `InpTrailX_ATRMult` = 2.0 es demasiado ajustado para NAS100 M5. A probar: 3.0 / 4.0, `InpTrailX_ATRStartRR` = 2.0 y `InpTrailX_SwingStartRR` = 2.0.
- Los pasos de optimización difieren del backtest completo (p. ej. v3.10 "Todos": 27,999 vs 30,671), así que comparar siempre con la misma corrida.

---

# Actualización: v3.12 (`Nova_Bot_v3_2`, ATR x3 y swing/ATR desde 2.0R)

| Métrica | v3.10 | v3.11 | v3.12 |
|---|---:|---:|---:|
| Beneficio neto | +30.67% | +27.70% | +26.49% |
| Profit Factor | 1.27 | 1.24 | 1.23 |
| Factor de recuperación | 3.06 | 2.73 | 2.72 |
| DD equidad máx. | 7.90% | 8.06% | 7.72% |
| Beneficio esperado | 30.37 | 27.30 | 26.15 |
| Operaciones | 1,010 | 1,015 | 1,013 |
| Mejor trade | 2,444 | 1,528 | 1,542 |

Optimización v3.12 (PF / beneficio / DD): S2C sola 1.49 / 8,005 / 3.29%, S1+S2C 1.27 / 21,956 / 6.89%, S2N+S2C 1.23 / 10,511 / 6.65%, todos 1.22 / 24,891 / 7.66%, S1 sola 1.22 / 15,513 / 6.96%, S1+S2N 1.18 / 18,265 / 7.52%, S2N sola 1.09 / 2,346 / 5.42%.

## Conclusión
- Aflojar el ATR (2 -> 3) y retrasar swing/ATR (1.5R -> 2.0R) **no recuperó** el resultado: v3.12 queda incluso por debajo de v3.11. El mejor trade sigue en ~1,540 (vs 2,444 de v3.10).
- Como el ATR más holgado no ayuda, la causa probable son los **escalones extra 1.20/1.50/1.80R** (SL a +0.70/+1.00/+1.30R), que en NAS100 se activan en retrocesos normales y sacan trades que luego llegaban a 4-5R.
- **v3.10 sigue siendo la mejor versión.** Próxima prueba sugerida: v3.10 + solo swing desde 2.0R (sin escalones extra ni ATR), o desactivar los escalones extra en v3.12.