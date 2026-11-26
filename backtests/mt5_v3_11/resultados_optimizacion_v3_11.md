# Resultados de Optimización - Nova_Bot_v3.11 (`Nova_Bot_v3_1`)

## Metadatos de la Prueba (Strategy Tester)

* **Plataforma / Servidor:** MetaTrader 5 (Pepperstone-Demo)
* **Asesor Experto (EA):** `Nova_Bot_v3_1` (v3.11)
* **Símbolo / Temporalidad:** `NAS100`, `M5`
* **Criterio de Ordenamiento:** Resultado (Profit Factor / Rentabilidad máxima descendiente)

## Tabla de Resultados de Optimización

| Paso (Pass) | Resultado (PF) | Beneficio | Total de operaciones | Beneficio esperado | Reducción % (Drawdown) | `InpEnableSetup1` | `InpEnableSetup2Nac` | `InpEnableSetup2Cont` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **4** | **1.55** | 8980.69 | 163 | **55.10** | **3.27%** | `false` | `false` | `true` |
| **5** | **1.29** | 24403.70 | 783 | 31.17 | 6.69% | `true` | `false` | `true` |
| **1** | **1.24** | 17261.65 | 700 | 24.66 | 6.79% | `true` | `false` | `false` |
| **6** | **1.23** | 10607.68 | 391 | 27.13 | 6.67% | `false` | `true` | `true` |
| **7** | **1.23** | **26325.82** | **1011** | 26.04 | 7.83% | `true` | `true` | `true` |
| **3** | **1.18** | 19074.90 | 928 | 20.55 | 7.81% | `true` | `true` | `false` |
| **2** | **1.05** | 1478.72 | 228 | 6.49 | 5.13% | `false` | `true` | `false` |
| **0** | 0.00 | 0.00 | 0 | 0.00 | 0.00% | `false` | `false` | `false` |

## Resumen de Desempeño por Combinación

* **Mejor Profit Factor y Menor Drawdown (Paso 4):** Solo `Setup 2 Continuación` activo (`PF 1.55`, `DD 3.27%`, `+$8,980.69` en `163` trades, esperanza matemática de `$55.10`).
* **Mejor Balance Riesgo/Retorno Multisetup (Paso 5):** `Setup 1` + `Setup 2 Continuación` (`PF 1.29`, `DD 6.69%`, `+$24,403.70` en `783` trades, esperanza de `$31.17`).
* **Mayor Beneficio Neto Total (Paso 7):** Todos los motores activos (`+$26,325.82` en `1,011` trades, `PF 1.23`, `DD 7.83%`).
* **Consistencia Individual:** Todos los motores individuales (`Pasos 1, 2 y 4`) cerraron en positivo (`PF 1.24`, `1.05` y `1.55` respectivamente), destacando el salto de rendimiento en `Setup 1` (`+$17,261.65`) y `Setup 2 Continuación` (`+$8,980.69`).