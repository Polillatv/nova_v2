# Análisis de la Curva de Balance y Patrimonio - Nova_Bot v3.13 (`Nova_Bot_v3.mq5`)

## 1. Metadatos del Gráfico (Strategy Tester - Graph)

* **Plataforma / Servidor:** MetaTrader 5 (Pepperstone-Demo)
* **Asesor Experto (EA):** `Nova_Bot_v3` (`v3.13`)
* **Símbolo / Temporalidad:** `NAS100`, `M5`
* **Periodo Evaluado (Eje X):** `2023.01.17` hasta `2026.08.17` (~3 años y 8 meses)
* **Rango Vertical Balance / Patrimonio (Eje Y):** `96,512` a `133,184` USD (Capital inicial: `100,000.00` USD)
* **Panel Inferior:** Carga del depósito (`0.0%` a `10.0%`)

## 2. Evolución Cronológica de la Curva

* **Q1 – Q2 2023 (`2023.01.17` – `2023.04.26`):** Breve retroceso inicial cerca de `98,258` USD, seguido de un fuerte impulso alcista hasta la zona de `109,500` – `110,482` USD (+10% en 4 meses).
* **H2 2023 – Q1 2024 (`2023.04.26` – `2024.05.06`):** Fase de consolidación lateral ascendente muy controlada entre `106,990` y `112,228` USD, absorbiendo los primeros meses de 2024 en torno a `109,500` USD sin comprometer el capital base.
* **Q2 2024 – Q1 2025 (`2024.05.06` – `2025.03.21`):** Expansión sostenida en dos ondas principales (mayo–agosto 2024 hasta `~122,706` USD y septiembre 2024–marzo 2025 alcanzando un máximo local cercano a `127,945` USD).
* **Q2 – Q4 2025 (`2025.03.21` – `2025.12`):** Fase de ajuste/drawdown más prolongada del backtest. La curva desciende gradualmente desde `~127,945` USD hasta marcar un valle en torno a `119,214` USD hacia finales de 2025 (correspondiente al drawdown máximo más bajo de toda la serie: **`7.18%`** sobre equidad y **`6.78%`** sobre balance).
* **2026 (`2026.01.12` – `2026.08.17`):** Recuperación limpia en el primer semestre (`119,214` $\rightarrow$ `125,500` USD) y aceleración marcada a partir de junio de 2026, superando con holgura los máximos previos hasta alcanzar la zona de `131,437` USD (cierre final en `130,198.83` USD).

## 3. Comportamiento de Equidad y Gestión de Riesgo

* **Récord de Linealidad y Control de Riesgo:** Esta iteración alcanza el mejor **LR Correlation (`0.92`)**, el menor **LR Standard Error (`3,184.17`)**, el mayor **Ratio de Sharpe (`4.01`)** y el menor **Drawdown máximo (`6.78%` balance / `7.18%` equidad)** de toda la familia `Nova_Bot_v3`.
* **Carga del Depósito (Deposit Load):** Se mantiene extremadamente baja y estable durante los casi 4 años, oscilando siempre por debajo del **`1.0%`** del margen disponible.