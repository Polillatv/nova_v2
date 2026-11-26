# Nova Bot v3 — Estrategia Nova (NAS100 M5 / Prop Firm Bullfy)

Expert Advisor (EA) en **MQL5** para **MetaTrader 5** que automatiza la **Estrategia Nova** sobre `NAS100` / `US100` en temporalidad **M5**, calibrado según el backtesting manual e incorporando protección estricta de reglas para cuentas de fondeo (**Bullfy Ltd.**).

---

## Estructura del Proyecto

```text
Bot Nova/
├── Nova_Bot_v3.mq5                  # EA estable (v3.10, trailing original)
├── Nova_Bot_v3_1.mq5                # EA v3.11: trailing ATR + swing (ver CHANGELOG)
├── Nova_Bot_v3_2.mq5                # EA v3.12: variante con ATR x3 y swing/ATR desde 2.0R (backtest: peor que v3.10)
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
│       └── PLAN_IMPLEMENTACION.txt  # Bitácora técnica de auditoría y evolución
│
├── backtests/                       # Registros y reportes de validación
│   ├── manual_2023_h1/              # Backtesting manual Forex Tester (Ene - Jun 2023)
│   └── mt5_v1_historico/            # Corridas históricas de referencia con v1 en MT5
│
└── archive/                         # Versiones anteriores (.mq5) conservadas como respaldo
    ├── Nova_Bot_v1.mq5
    ├── Nova_Bot_v2.mq5
    └── Nova_Bot_v2_3_Clone.mq5
```

> **Nota para MetaTrader 5:** En la raíz solo se compila `Nova_Bot_v3.ex5` y se eliminaron los `.ex5` antiguos de `archive/`, de modo que en el Navegador y en el Probador de Estrategias aparezca únicamente **`Nova_Bot_v3`**.

---

## Resumen de la Estrategia (`v3.10`)

- **Rango Base Diario:** `02:00 NY` a `07:00 NY` (cálculo automático de horario de verano DST entre Nueva York y el servidor del bróker).
- **Ventana Operativa NY:** Evaluación estructural y ejecución desde las `08:00 NY` hasta las `15:00 NY` (gestión hasta `15:45 NY`).
- **Sesión Asia / Domingos (Opcional):** `18:00 NY` a `21:30 NY` conservando el mismo rango base (en domingos toma automáticamente el último rango válido del viernes).
- **Setups y Prioridad:**
  - **[Setup 1](docs/setups/setup_1/setup1.md):** Quiebre inicial `1QR >= 0.20%` con cuerpo + `1Qe` + orden Stop directa sobre `2Qe`. Sigue siendo operable aunque se haya activado `S2N`.
  - **[Setup 2 Nacimiento](docs/setups/setup_2_nacimiento/setup2_nacimiento.md):** Barrido/absorción `1QR >= 0.05%` + `CH` + reacción al `50%` + `BOS` con entrada Stop al `75%` del rango.
  - **[Setup 2 Continuación](docs/setups/setup_2_continuacion/setup2_continuacion.md):** Tras barrido inicial, quiebre opuesto `2QR >= 0.15%` con cuerpo + `1Qe` + orden Stop directa sobre `2Qe`. **Al activarse `S2C`, invalida automáticamente `Setup 1`**.
  - **[Setup 3 No Operable](docs/setups/setup_3_no_operable/setup3_no_operable.md):** Bloquea nuevas entradas del día si el precio rompe con cuerpo por ambos extremos del rango y retoma dirección contraria cruzando el `50%`.
- **Gestión del Trade y Salidas:**
  - **Escalones RR:** `+0.50R -> SL a -0.25R` | `+0.80R -> SL a +0.50R` | `+1.80R -> SL a +1.15R` | **`>= +2.00R` -> Trailing por swings fractales reales M5** hasta el TP (`5R` en S1/S2C, `4R` en S2N).
  - **Hora de Gracia:** Evaluación única a los `60 min` (cierra solo si aún no hubo momentum `maxRR < 0.50` y `RR < 0.20`).
  - **Apertura `09:30 NY` y Cierre `15:40 NY`:** Espera cierre de vela `09:30-09:35 NY` si el `PE` cae justo antes de la apertura; cierra operaciones planas/levemente negativas a las `15:40 NY`.
  - **Cumplimiento Bullfy Ltd.:** Filtro de noticias de carpeta roja (`[T-5m, T+5m]` respetando antigüedad mínima de cierre), salida preventiva `90 min` antes de **FOMC** y freno diario de Drawdown.

---

## Versiones

| Archivo | Versión | Trailing | Magics |
|---|---|---|---|
| `Nova_Bot_v3.mq5` | 3.10 | Escalones 0.50/0.80/1.80R + swing M5 desde 2.0R | 2026xx |
| `Nova_Bot_v3_1.mq5` | 3.11 | Modo `TRAIL_ATR_SWING`: escalones extra 1.20/1.50/1.80R, swing desde 1.5R, piso ATR(M5) x2.0 desde 1.5R | 2036xx |
| `Nova_Bot_v3_2.mq5` | 3.12 | Igual que 3.11 pero swing y piso ATR(M5) x3.0 desde 2.0R | 2046xx |

Resultados 2023-2026 (todos los setups): v3.10 +30.67% PF 1.27 | v3.11 +27.70% PF 1.24 | v3.12 +26.49% PF 1.23 (v3.10 sigue siendo la mejor). Ver [comparativa](backtests/COMPARATIVA_v3_vs_v3_1.md).

Las versiones usan magics y claves GlobalVariable distintas, así que pueden convivir en el mismo terminal. Detalle en [CHANGELOG](docs/historial_cambios/CHANGELOG.md).

---

## Uso en MetaTrader 5

1. **Compilar:** Abrir `Nova_Bot_v3.mq5` en **MetaEditor 5** y presionar `F7` (`0 errors, 0 warnings`).
2. **Noticias en vivo (Demo / Real):** En MT5 ir a `Herramientas -> Opciones -> Asesores Expertos`, activar *Permitir WebRequest para las URL listadas* y agregar:
   ```text
   https://nfs.faireconomy.media
   ```
3. **Probador de Estrategias (Backtesting):**
   - Activo `NAS100`, temporalidad `M5`, modelado *Cada tick basado en ticks reales*.
   - En la pestaña **Parámetros de entrada (Inputs)** hacer **Clic derecho -> Restablecer (Reset)** tras actualizar versiones para evitar valores viejos en caché.
   - Para auditar decisiones vela por vela, activar `InpDebugTrace = true` (genera el CSV en `Terminal\Common\Files\Nova_v3_trace_*.csv`).

---

## Comandos Rápidos de Git

Para subir nuevos cambios a GitHub desde la carpeta del proyecto:

```powershell
git status
git add -A
git commit -m "Descripcion breve de tus cambios"
git push origin HEAD:ModificacionDiego
```
