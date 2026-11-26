# Resultados de Optimización - Nova_Bot_v3.2 (`Nova_Bot_v3_2`)

## Metadatos de la Prueba (Strategy Tester)

* **Plataforma / Servidor:** MetaTrader 5 (Pepperstone-Demo)
* **Asesor Experto (EA):** `Nova_Bot_v3_2` (v3.2)
* **Símbolo / Temporalidad:** `NAS100`, `M5`
* **Criterio de Ordenamiento:** Resultado (Profit Factor / Rentabilidad máxima descendiente)

## Tabla de Resultados de Optimización

| Paso (Pass) | Resultado (PF) | Beneficio | Total de operaciones | Beneficio esperado | Reducción % (Drawdown) | `InpEnableSetup1` | `InpEnableSetup2Nac` | `InpEnableSetup2Cont` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **4** | **1.49** | 8004.96 | 163 | **49.11** | **3.29%** | `false` | `false` | `true` |
| **5** | **1.27** | 21956.42 | 781 | 28.11 | 6.89% | `true` | `false` | `true` |
| **6** | **1.23** | 10511.07 | 391 | 26.88 | 6.65% | `false` | `true` | `true` |
| **7** | **1.22** | **24891.09** | **1009** | 24.67 | 7.66% | `true` | `true` | `true` |
| **1** | **1.22** | 15512.97 | 698 | 22.22 | 6.96% | `true` | `false` | `false` |
| **3** | **1.18** | 18265.21 | 926 | 19.72 | 7.52% | `true` | `true` | `false` |
| **2** | **1.09** | 2345.65 | 228 | 10.29 | 5.42% | `false` | `true` | `false` |
| **0** | 0.00 | 0.00 | 0 | 0.00 | 0.00% | `false` | `false` | `false` |

## Resumen de Desempeño por Combinación

* **Mejor Profit Factor y Menor Drawdown (Paso 4):** Solo `Setup 2 Continuación` activo (`PF 1.49`, `DD 3.29%`, `+$8,004.96` en `163` trades, esperanza matemática de `$49.11`).
* **Mejor Balance Riesgo/Retorno Multisetup (Paso 5):** `Setup 1` + `Setup 2 Continuación` (`PF 1.27`, `DD 6.89%`, `+$21,956.42` en `781` trades, esperanza de `$28.11`).
* **Mayor Beneficio Neto Total (Paso 7):** Todos los motores activos (`+$24,891.09` en `1,009` trades, `PF 1.22`, `DD 7.66%`).
* **Recuperación de `Setup 2 Nacimiento` (Paso 2):** Frente a `v3.11` (`+$1,478.72`, `PF 1.05`), en `v3.2` este motor recupera terreno cerrando en `+$2,345.65` (`PF 1.09`, esperanza de `$10.29`), manteniendo a todos los motores individuales en positivo (`1.22`, `1.09` y `1.49`).