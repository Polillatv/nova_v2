# Resultados de Optimización - Nova_Bot_v3

## Metadatos de la Prueba (Strategy Tester)

* **Plataforma / Servidor:** MetaTrader 5 (Pepperstone-Demo)

* **Asesor Experto (EA):** `Nova_Bot_v3`

* **Símbolo / Temporalidad:** `NAS100`, `M5`

* **Criterio de Ordenamiento:** Resultado (Profit Factor / Rentabilidad máxima descendiente)

## Tabla de Resultados de Optimización

| Paso (Pass) | Resultado (PF) | Beneficio | Total de operaciones | Beneficio esperado | Reducción % (Drawdown) | `InpEnableSetup1` | `InpEnableSetup2Nac` | `InpEnableSetup2Cont` | 
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | 
| **4** | **1.49** | 7931.37 | 162 | **48.96** | **3.37%** | `false` | `false` | `true` | 
| **6** | **1.28** | 13219.00 | 390 | 33.89 | 5.16% | `false` | `true` | `true` | 
| **5** | **1.27** | 22282.80 | 777 | 28.68 | 7.93% | `true` | `false` | `true` | 
| **7** | **1.24** | **27999.87** | **1005** | 27.86 | 8.09% | `true` | `true` | `true` | 
| **1** | **1.22** | 15425.46 | 693 | 22.26 | 7.47% | `true` | `false` | `false` | 
| **3** | **1.20** | 21128.91 | 921 | 22.94 | 8.03% | `true` | `true` | `false` | 
| **2** | **1.18** | 4911.93 | 228 | 21.54 | 4.44% | `false` | `true` | `false` | 
| **0** | 0.00 | 0.00 | 0 | 0.00 | 0.00% | `false` | `false` | `false` | 

## Resumen de Desempeño por Combinación

* **Mejor Profit Factor y Menor Drawdown (Paso 4):** Solo `Setup 2 Continuación` activo (`PF 1.49`, `DD 3.37%`, `+$7,931.37` en `162` trades, esperanza matemática de `$48.96`).

* **Mayor Beneficio Neto Total (Paso 7):** Todos los motores activos (`+$27,999.87` en `1,005` trades, `PF 1.24`, `DD 8.09%`).

* **Mejor Balance Riesgo/Retorno Multisetup (Paso 6):** `Setup 2 Nacimiento` + `Setup 2 Continuación` (`PF 1.28`, `DD 5.16%`, `+$13,219.00` en `390` trades).

* **Consistencia Individual:** Todos los motores individuales (`Pasos 1, 2 y 4`) cerraron con Profit Factor positivo (`1.22`, `1.18` y `1.49` respectivamente).