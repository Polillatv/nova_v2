# Auditoría Histórica 4 Años — Nova Bot `v3.14` (`InpEnableAsiaSession = true`)

- **Archivo de traza analizado:** `Nova_v3_trace_InpEnableAsiaSession_=_true.csv` (`426,781` eventos)
- **Ventana temporal:** `2023.01.03` – `2026.11.25` (`47` meses)
- **Configuración:** `Nova_Bot_v3.mq5` (`v3.14`), `TRAIL_M5_SWING`, `InpGraceCloseMarket = false`, `InpClose1540Rule = false`, **`InpEnableAsiaSession = true`**.

---

## 1. Resumen Global (`2023–2026` vs `v3.13`)

| Métrica (`2023 – 2026`) | `v3.13` (`mt5_v3_13/`, Asia OFF) | **`v3.14` (`mt5_v3_14/`, Asia ON)** | Lectura Técnica |
| :--- | :---: | :---: | :--- |
| **Ganancia Neta (`R` / `%` @ `0.5%`)** | **`~+60.4R` (`+30.20%`)** | `+31.14R` (`+16.18%` compuesto) | `v3.14` ganó fuerte en `2023–2024` (`+32.19R`), pero devolvió ganancias en `2025–2026` (`-1.06R`) |
| **Retorno Compuesto @ `1.0%` riesgo** | — | **`+33.46%`** (`DD Balance 12.33%`) | — |
| **Max Balance Drawdown (@ `0.5%`)** | `6.78%` | **`6.16%` (`12.28R`)** | **Nuevo mínimo de Drawdown de Balance (`6.16%`)** |
| **Profit Factor** | **`1.26`** | `1.14` (`+246.59R` / `-215.45R`) | Penalizado por `_GRACE_SWING` (`-39.78R`) y devoluciones sin `BOS` |
| **Operaciones Cerradas** | `1,013` | `999` (`789` NY + `210` Asia) | `0 / 1,323` bugs `1QR==1Qe` · `0` fills fantasma `07:00` |
| **Win Rate (`> +0.02R`)** | **`44.72%`** | `39.74%` (`397` G / `587` P / `15` BE) | Ratio medio `+0.62R` vs `-0.37R` (`1.68 : 1`) |
| **Mejor / Peor Operación** | `+$2,444.17` (`~5R`) | **`+4.00R` (`TP_HIT S2N`)** / `-1.02R` | Primeros `TP_HIT` limpios alcanzados |
| **Meses Positivos** | — | `26 / 47` (`55.3%`) | — |

---

## 2. Desglose por Año, Sesión y Setup

### Por Año
| Año | Total Trades | Neto Total (`R`) | Retorno (`@0.5%`) | Sesión NY (`R`) | Sesión Asia (`R`) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **2023** | `247` | **`+19.36R`** | **`+9.68%`** | **`+20.13R`** (`211` tr) | `-0.77R` (`36` tr) |
| **2024** | `259` | **`+12.83R`** | **`+6.42%`** | **`+10.13R`** (`201` tr) | **`+2.71R`** (`58` tr) |
| **2025** | `260` | `+0.23R` | `+0.11%` | `-5.74R` (`207` tr) | **`+5.97R`** (`53` tr) |
| **2026 (Ene–Nov)** | `233` | `-1.29R` | `-0.64%` | `+1.46R` (`170` tr) | `-2.75R` (`63` tr) |

### Por Setup (`2023–2026`)
| Setup | Total Trades | Neto Total (`R`) | NY (`Trades` / `R`) | Asia (`Trades` / `R`) |
| :--- | :---: | :---: | :---: | :---: |
| **`S1` (Setup 1)** | `583` | **`+14.54R`** | `441` tr / **`+13.45R`** | `142` tr / `+1.10R` |
| **`S2N` (Nacimiento)** | `260` | **`+9.61R`** | `228` tr / **`+6.40R`** | `32` tr / **`+3.21R`** |
| **`S2C` (Continuación)** | `156` | **`+6.98R`** | `120` tr / **`+6.13R`** | `36` tr / `+0.85R` |

---

## 3. Las 3 Fugas Críticas Descubiertas en los 4 Años (Hoja de Ruta `v3.15`)

1. **Bug Crítico de `REJECT` en `ReactivarParaSesionAsia()` (`400,518` rechazos en `39` días):**
   - Al activar `InpEnableAsiaSession = true`, cuando `S2C` había invalidado a `S1` en NY y el precio cerraba en el extremo opuesto del rango, `ReactivarParaSesionAsia()` revivía `S1` a las `18:00 NY` con la dirección vieja, intentando colocar órdenes con `SL` del lado incorrecto (`ret=10016 invalid stops`) en cada tick. **Corregirlo es obligatorio para cumplir las reglas de servidor de Bullfy Ltd.**
2. **Sangría en `*_GRACE_SWING` (`72` cierres = `-39.78R`):**
   - El fallback de micro-swing `fBars = 1` a los `60` minutos cuando el precio está más profundo que `-0.25R` coloca el SL pegado al precio actual y cristaliza pérdidas medias de `-0.55R` (`42` en `S1` = `-24.08R`, `19` en `S2N` = `-9.57R`, `11` en `S2C` = `-6.13R`).
3. **Devolución de ganancias en `2025–2026` por `InpManualSwing_RequireBOS = true` hasta `+2.00R` (`162` trades cerrados en `_ASIA_BE` a `+0.05R`):**
   - En regímenes de giros en V (`2025–2026`), las operaciones que avanzan `+1.00R` a `+1.85R` en un solo impulso sin segundo `BOS` mantienen el SL en `-0.25R` y devuelven todo el recorrido hasta `-0.25R` o `+0.05R` (`_ASIA_BE`). Liberar el fractal M5 sin exigir `BOS` desde `+1.00R` y añadir un piso suave en `+1.25R -> +0.60R` combina los runners de `v3.14` con la defensa de `v3.13`.
