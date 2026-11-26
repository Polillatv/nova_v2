# Nova Bot v3 — Estrategia Nova (NAS100 M5 / Prop Firm Bullfy)

Expert Advisor (EA) en **MQL5** para **MetaTrader 5** que automatiza la **Estrategia Nova** sobre `NAS100` / `US100` en temporalidad **M5**, calibrado según el backtesting manual, validado en histórico `2023–2026` (`185M` ticks reales) e incorporando protección estricta de reglas para cuentas de fondeo (**Bullfy Ltd.**).

---

## Estructura del Proyecto

```text
Bot Nova/
├── Nova_Bot_v3.mq5                  # Único EA productivo unificado (v3.13 Híbrido)
├── Nova_Bot_v3.ex5                  # Ejecutable compilado local para MT5 (ignorado en Git)
├── README.md                        # Guía general del proyecto
├── .gitignore                       # Exclusión de binarios (.ex5), logs y trazas CSV
│
├── docs/                            # Especificación de reglas y documentación técnica
│   ├── bullfy/
│   │   └── reglamento_bullfy.txt    # Cláusulas operativas y de noticias de Bullfy Ltd.
│   ├── setups/
│   │   ├── setup_1/                 # Reglas de Setup 1 + láminas + capturas TradingView
│   │   ├── setup_2_nacimiento/      # Reglas de Setup 2 Nacimiento + láminas + capturas TV
│   │   ├── setup_2_continuacion/    # Reglas de Setup 2 Continuación + láminas + capturas TV
│   │   └── setup_3_no_operable/     # Filtro de exclusión Setup 3 (barrido bilateral + giro)
│   └── historial_cambios/
│       ├── CHANGELOG.md             # Historial de versiones (v3.10 -> v3.13)
│       └── PLAN_IMPLEMENTACION.txt  # Bitácora técnica de auditoría y evolución
│
├── backtests/                       # Registros, optimizaciones y comparativas (nomenclatura unificada)
│   ├── COMPARATIVA_FAMILIA_v3.md    # Comparativa maestra v3.10 vs v3.11 vs v3.12 vs v3.13
│   ├── manual_2023_h1/              # Backtesting manual Forex Tester (Ene - Jun 2023)
│   ├── mt5_v1_ablacion/             # Corridas iniciales de ablación en MT5
│   ├── mt5_v3_10/                   # Backtest 99% y optimización v3.10 (NOVA_SWING global)
│   ├── mt5_v3_11/                   # Backtest 99% y optimización v3.11 (ATR x2 tick global)
│   ├── mt5_v3_12/                   # Backtest 99% y optimización v3.12 (ATR x3 @ 2.0R global)
│   └── mt5_v3_13/                   # Backtest 99% y optimización v3.13 (Híbrido productivo actual)
│
└── archive/                         # Versiones anteriores (.mq5) conservadas como respaldo
    ├── Nova_Bot_v1_ablacion.mq5
    ├── Nova_Bot_v2_0.mq5
    ├── Nova_Bot_v2_3.mq5
    ├── Nova_Bot_v3_11.mq5
    └── Nova_Bot_v3_12.mq5
```

> **Convención única de versiones:** Todo el repositorio utiliza la numeración exacta del `#property version` del código (`v3.10`, `v3.11`, `v3.12` y **`v3.13`**) tanto en carpetas (`mt5_v3_10` ... `mt5_v3_13`) como en `archive/` y reportes, evitando mezclar `v3.2`/`v3.3` con `v3.12`/`v3.13`.

---

## Arquitectura Operativa (`v3.13` Híbrida Unificada)

- **Rango Base Diario:** `02:00 NY` a `07:00 NY` (cálculo automático de horario de verano DST entre Nueva York y el bróker).
- **Ventana Operativa NY:** Evaluación estructural y ejecución desde las `08:00 NY` hasta las `15:00 NY` (gestión hasta `15:45 NY`).
- **Sesión Asia / Domingos (Opcional):** `18:00 NY` a `21:30 NY` conservando el mismo rango base (en domingos utiliza el último rango válido del viernes).
- **Setups y Prioridad:**
  - **[Setup 1](docs/setups/setup_1/setup1.md):** Quiebre inicial `1QR >= 0.20%` con cuerpo + `1Qe` + orden Stop directa sobre `2Qe`. Sigue operable aunque se active `S2N`.
  - **[Setup 2 Nacimiento](docs/setups/setup_2_nacimiento/setup2_nacimiento.md):** Barrido/absorción `1QR >= 0.05%` + `CH` + reacción al `50%` + `BOS` con entrada Stop al `75%` del rango.
  - **[Setup 2 Continuación](docs/setups/setup_2_continuacion/setup2_continuacion.md):** Tras barrido inicial, quiebre opuesto `2QR >= 0.15%` con cuerpo + `1Qe` + orden Stop directa sobre `2Qe`. **Al activarse `S2C`, invalida automáticamente `Setup 1`**.
  - **[Setup 3 No Operable](docs/setups/setup_3_no_operable/setup3_no_operable.md):** Bloquea nuevas entradas del día si el precio rompe con cuerpo por ambos extremos del rango y retoma dirección contraria cruzando el `50%`.
- **Trailing Híbrido Desacoplado por Motor (`v3.13`):**
  - **Motor `Qe` (`Setup 1` y `Setup 2 Continuación` -> `InpTrailModeQe = TRAIL_ATR_SWING`):** Escalones `0.50 -> -0.25R`, `0.80 -> +0.50R`, `1.20 -> +0.70R`, `1.50 -> +1.00R`, `1.80 -> +1.30R` + swings fractales M5 desde `+1.50R` + respaldo `ATR(14)` al cierre M5 solo mientras no exista swing fractal sobre el piso.
  - **Motor `Setup 2 Nacimiento` (`InpTrailModeS2N = TRAIL_NOVA_SWING`):** Escalones amplios `0.50 -> -0.25R`, `0.80 -> +0.50R`, `1.80 -> +1.15R` + swings fractales desde `+2.00R` hasta el TP (`4R`).
- **Protección Prop Firm (Bullfy Ltd.):** Ventana restringida en noticias rojas (`[T-5m, T+5m]`), salida preventiva `90 min` antes de **FOMC** y guardia diaria de Drawdown.

---

## Resumen de Rendimiento (`NAS100 M5` `2023.01 – 2026.10`, `99%` Ticks)

| Versión | Carpeta Reportes | Retorno Neto | Equity DD Máx. | Sharpe | Recovery | Mejor Trade | Pass 7 (Optimizador) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **v3.10** | [`backtests/mt5_v3_10/`](backtests/mt5_v3_10/reporte_maestro_v3_10.md) | **`+30.67%`** | `7.90%` | `3.64` | `3.06` | **`+$2,444`** | `+$28,000` (`DD 8.09%`) |
| **v3.11** | [`backtests/mt5_v3_11/`](backtests/mt5_v3_11/reporte_maestro_v3_11.md) | `+27.70%` | `8.06%` | `3.92` | `2.73` | `+$1,528` | `+$26,326` (`DD 7.83%`) |
| **v3.12** | [`backtests/mt5_v3_12/`](backtests/mt5_v3_12/reporte_maestro_v3_12.md) | `+26.49%` | `7.72%` | `3.59` | `2.72` | `+$1,542` | `+$24,891` (`DD 7.66%`) |
| **v3.13 (Actual)** | [`backtests/mt5_v3_13/`](backtests/mt5_v3_13/reporte_maestro_v3_13.md) | **`+30.20%`** | **`7.18%`** | **`4.01`** | **`3.29`** | **`+$2,444`** | **`+$28,549` (`DD 7.03%`)** |

Detalle completo en [COMPARATIVA_FAMILIA_v3.md](backtests/COMPARATIVA_FAMILIA_v3.md) y [CHANGELOG.md](docs/historial_cambios/CHANGELOG.md).

---

## Uso en MetaTrader 5

1. **Compilar:** Abrir `Nova_Bot_v3.mq5` en **MetaEditor 5** y presionar `F7` (`0 errors, 0 warnings`).
2. **Noticias en vivo (Demo / Real):** En MT5 ir a `Herramientas -> Opciones -> Asesores Expertos`, activar *Permitir WebRequest para las URL listadas* y agregar:
   ```text
   https://nfs.faireconomy.media
   ```
3. **Probador de Estrategias (Backtesting):**
   - Activo `NAS100`, temporalidad `M5`, modelado *Cada tick basado en ticks reales*.
   - En **Parámetros de entrada (Inputs)** hacer **Clic derecho -> Restablecer (Reset)** para cargar los valores por defecto de **`v3.13`** (`"NOVA BOT v3.13"` en el HUD).

---

## Comandos Rápidos de Git

```powershell
git status
git add -A
git commit -m "Descripcion breve de tus cambios"
git push origin HEAD:ModificacionDiego
```
