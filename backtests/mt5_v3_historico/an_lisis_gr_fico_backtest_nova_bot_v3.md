# Análisis de la Curva de Balance y Patrimonio - Nova_Bot_v3

## 1. Metadatos del Gráfico (Strategy Tester - Graph)
* **Plataforma / Servidor:** MetaTrader 5 (Pepperstone-Demo)
* **Asesor Experto (EA):** `Nova_Bot_v3`
* **Símbolo / Temporalidad:** `NAS100`, `M5`
* **Periodo Evaluado (Eje X):** `2023.01.11` hasta `2026.10.12` (~3 años y 9 meses)
* **Rango Vertical Balance / Patrimonio (Eje Y):** `96,513` a `134,651` USD (Capital inicial: `100,000.00` USD)
* **Panel Inferior:** Carga del depósito (`0.0%` a `10.0%`)

## 2. Evolución Cronológica de la Curva
* **Q1 – Q2 2023 (`2023.01.11` – `2023.06.09`):** Inicio con leve retroceso inicial cerca de `98,330` USD, seguido de un fuerte impulso alcista que lleva el balance hasta la zona de `109,226` – `110,000` USD (+10% en 5 meses).
* **H2 2023 – Q1 2024 (`2023.06.09` – `2024.05.31`):** Fase de consolidación y lateralización amplia entre `108,500` y `113,200` USD, con retroceso controlado entre enero y abril de 2024 hacia `109,226` USD sin comprometer el capital base.
* **Q2 2024 – Q1 2025 (`2024.05.31` – `2025.02.18`):** Expansión sostenida en dos tramos principales (junio–agosto 2024 hasta `~122,500` USD y noviembre 2024–febrero 2025 alcanzando un pico local cercano a `126,500` USD).
* **Q2 – Q4 2025 (`2025.02.18` – `2025.12`):** Periodo de drawdown/consolidación más prolongado del backtest. La curva desciende gradualmente desde `~126,500` USD hasta tocar un valle en torno a `116,800` – `117,000` USD hacia finales de 2025 (correspondiente al drawdown máximo del `7.90%` sobre equidad).
* **2026 (`2026.01.12` – `2026.10.12`):** Recuperación constante en el primer semestre (`117,000` $\rightarrow$ `123,500` USD) y aceleración marcada entre julio y octubre de 2026, marcando nuevos máximos históricos por encima de `131,019` USD (cierre final en torno a `130,671` USD).

## 3. Comportamiento de Equidad y Gestión de Riesgo
* **Alineación Balance (Azul) vs. Patrimonio (Verde):** La línea verde de patrimonio acompaña muy de cerca a la curva azul de balance durante todo el histórico, con picos flotantes positivos frecuentes (operaciones que corren a favor) y sin desviaciones flotantes negativas profundas.
* **Carga del Depósito (Deposit Load):** Se mantiene extremadamente baja y estable durante los casi 4 años, oscilando mayoritariamente por debajo del **`1.0%`** del margen disponible (sin picos de sobreapalancamiento).