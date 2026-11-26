# Resultados de Optimización - Nova_Bot v3.13 (`Nova_Bot_v3.mq5`)

## Metadatos de la Prueba (Strategy Tester)

* **Plataforma / Servidor:** MetaTrader 5 (Pepperstone-Demo)
* **Asesor Experto (EA):** `Nova_Bot_v3` (`v3.13`)
* **Símbolo / Temporalidad:** `NAS100`, `M5`
* **Criterio de Ordenamiento:** Resultado (Profit Factor / Rentabilidad máxima descendiente)

## Tabla de Resultados de Optimización

| Paso (Pass) | Resultado (PF) | Beneficio | Total de operaciones | Beneficio esperado | Reducción % (Drawdown) | `InpEnableSetup1` | `InpEnableSetup2Nac` | `InpEnableSetup2Cont` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **4** | **1.51** | 8243.94 | 163 | **50.58** | **3.27%** | `false` | `false` | `true` |
| **6** | **1.29** | 13587.83 | 391 | 34.75 | 5.33% | `false` | `true` | `true` |
| **5** | **1.27** | 22538.31 | 781 | 28.86 | 6.92% | `true` | `false` | `true` |
| **7** | **1.24** | **28549.46** | **1009** | 28.29 | 7.03% | `true` | `true` | `true` |
| **1** | **1.23** | 16158.06 | 698 | 23.15 | 6.80% | `true` | `false` | `false` |
| **3** | **1.21** | 21813.02 | 926 | 23.56 | 6.72% | `true` | `true` | `false` |
| **2** | **1.18** | 4911.93 | 228 | 21.54 | 4.44% | `false` | `true` | `false` |
| **0** | 0.00 | 0.00 | 0 | 0.00 | 0.00% | `false` | `false` | `false` |

## Resumen de Desempeño por Combinación

* **Mejor Profit Factor y Menor Drawdown (Paso 4):** Solo `Setup 2 Continuación` activo (`PF 1.51`, `DD 3.27%`, `+$8,243.94` en `163` trades, esperanza matemática de `$50.58`).
* **Mejor Balance Riesgo/Retorno Multisetup (Paso 6):** `Setup 2 Nacimiento` + `Setup 2 Continuación` (`PF 1.29`, `DD 5.33%`, `+$13,587.83` en `391` trades, esperanza de `$34.75`).
* **Mayor Beneficio Neto Total (Paso 7):** Todos los motores activos (`+$28,549.46` en `1,009` trades, `PF 1.24`, con un drawdown mínimo de apenas **`7.03%`**).
* **Solidez Total en Motores Individuales:** Todos los motores individuales superan con holgura el umbral de rentabilidad (`Setup 1` en `+$16,158.06` / `PF 1.23` / `DD 6.80%`; `Setup 2 Nacimiento` en `+$4,911.93` / `PF 1.18` / `DD 4.44%`; `Setup 2 Continuación` en `+$8,243.94` / `PF 1.51` / `DD 3.27%`).