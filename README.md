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
│       ├── CHANGELOG.md             # Historial resumido de versiones (v3.10 -> v3.13)
│       └── PLAN_IMPLEMENTACION.txt  # Bitácora técnica de auditoría y evolución
│
├── backtests/                       # Registros, optimizaciones y comparativas
│   ├── COMPARATIVA_v3_vs_v3_1.md    # Comparativa cuantitativa v3.10 vs v3.11 vs v3.12
│   ├── manual_2023_h1/              # Backtesting manual Forex Tester (Ene - Jun 2023)
│   ├── mt5_v1_historico/            # Corridas históricas iniciales (v1)
│   ├── mt5_v3_historico/            # Backtest 99% y optimización v3.10 (2023 - 2026)
│   ├── mt5_v3_1_historico/          # Backtest 99% y optimización v3.11 (2023 - 2026)
│   └── mt5_v3_2_historico/          # Backtest 99% y optimización v3.12 (2023 - 2026)
│
└── archive/                         # Versiones anteriores (.mq5) conservadas como respaldo
    ├── Nova_Bot_v1.mq5
    ├── Nova_Bot_v2.mq5
    ├── Nova_Bot_v2_3_Clone.mq5
    ├── Nova_Bot_v3_1.mq5            # Experimento v3.11 (ATR x2 global)
    └── Nova_Bot_v3_2.mq5            # Experimento v3.12 (ATR x3 global desde 2.0R)
```

> **Nota para MetaTrader 5:** En la raíz solo se compila `Nova_Bot_v3.ex5` (`v3.13`), mientras que las variantes experimentales (`v3_1`, `v3_2`) quedan resguardadas en `archive/` sin `.ex5` para mantener limpio el Navegador y el Probador de Estrategias.

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
  - **Motor `Qe` (`Setup 1` y `Setup 2 Continuación` -> `InpTrailModeQe = TRAIL_ATR_SWING`):**
    - Escalones: `+0.50R -> -0.25R`, `+0.80R -> +0.50R`, `+1.20R -> +0.70R`, `+1.50R -> +1.00R`, `+1.80R -> +1.30R`.
    - Desde `+1.50R` sigue **swings fractales reales M5** hasta el TP (`5R`).
    - **Respaldo ATR inteligente (`InpTrailX_ATROnlyWithoutSwing = true`, `InpTrailX_ATROnBarClose = true`):** Evalúa `ATR(14)` al cierre de vela M5 **únicamente cuando aún no se formó un swing fractal por encima del piso**, protegiendo espigas verticales en V sin cortar prematuramente los recorridos tendenciales hacia `5R`.
  - **Motor `Setup 2 Nacimiento` (`InpTrailModeS2N = TRAIL_NOVA_SWING`):**
    - Escalones amplios (`+0.50R -> -0.25R`, `+0.80R -> +0.50R`, `+1.80R -> +1.15R`) + swings fractales desde `+2.00R` hasta el TP (`4R`), dando aire al retesteo natural del borde `100% FINAL` del rango.
- **Protección Prop Firm (Bullfy Ltd.):** Ventana restringida en noticias de carpeta roja (`[T-5m, T+5m]` respetando antigüedad mínima de cierre), salida preventiva `90 min` antes de **FOMC** y guardia diaria de Drawdown.

---

## Evolución de Versiones (Backtest `NAS100 M5` `2023–2026`, `99%` Ticks)

| Versión | Archivo | Estrategia de Trailing | Todos Activos | `S1 + S2C` (Pass 5) | `Solo S2N` (Pass 2) |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **v3.10** | `Nova_Bot_v3.mq5` *(prev)* | `NOVA_SWING` global | **`+30.67%` \| PF `1.27`** | `+$22,283` \| DD `7.93%` | **`+$4,912` \| PF `1.18`** |
| **v3.11** | `archive/Nova_Bot_v3_1.mq5` | `ATR_SWING` (`x2`, tick) global | `+27.70%` \| PF `1.24` | **`+$24,404` \| DD `6.69%`** | `+$1,479` \| PF `1.05` |
| **v3.12** | `archive/Nova_Bot_v3_2.mq5` | `ATR_SWING` (`x3` @ `2.0R`) global | `+26.49%` \| PF `1.23` | `+$21,956` \| DD `6.89%` | `+$2,346` \| PF `1.09` |
| **v3.13** | **`Nova_Bot_v3.mq5`** *(actual)* | **Híbrido (`Qe`: `ATR_SWING` fallback cierre M5 + `S2N`: `NOVA_SWING`)** | *Listo para validar* | *Combina Pass 5 v3.11* | *Combina Pass 2 v3.10* |

Detalle completo en [CHANGELOG.md](docs/historial_cambios/CHANGELOG.md) y [COMPARATIVA_v3_vs_v3_1.md](backtests/COMPARATIVA_v3_vs_v3_1.md).

---

## Uso en MetaTrader 5

1. **Compilar:** Abrir `Nova_Bot_v3.mq5` en **MetaEditor 5** y presionar `F7` (`0 errors, 0 warnings`).
2. **Noticias en vivo (Demo / Real):** En MT5 ir a `Herramientas -> Opciones -> Asesores Expertos`, activar *Permitir WebRequest para las URL listadas* y agregar:
   ```text
   https://nfs.faireconomy.media
   ```
3. **Probador de Estrategias (Backtesting):**
   - Activo `NAS100`, temporalidad `M5`, modelado *Cada tick basado en ticks reales*.
   - En **Parámetros de entrada (Inputs)** hacer **Clic derecho -> Restablecer (Reset)** para cargar los valores por defecto de **`v3.13`** (el HUD mostrará `"NOVA BOT v3.13"`).
   - Para auditar decisiones vela por vela, activar `InpDebugTrace = true` (`Terminal\Common\Files\Nova_v3_trace_*.csv`).

---

## Comandos Rápidos de Git

```powershell
git status
git add -A
git commit -m "Descripcion breve de tus cambios"
git push origin HEAD:ModificacionDiego
```
