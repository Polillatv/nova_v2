# Análisis de la Curva de Balance y Patrimonio - Nova_Bot_v3.11 (`Nova_Bot_v3_1`)

## 1. Metadatos del Gráfico (Strategy Tester - Graph)

* **Plataforma / Servidor:** MetaTrader 5 (Pepperstone-Demo)
* **Asesor Experto (EA):** `Nova_Bot_v3_1` (v3.11)
* **Símbolo / Temporalidad:** `NAS100`, `M5`
* **Periodo Evaluado (Eje X):** `2023.01.13` hasta `2026.09.21` (~3 años y 8 meses)
* **Rango Vertical Balance / Patrimonio (Eje Y):** `96,802` a `131,638` USD (Capital inicial: `100,000.00` USD)
* **Panel Inferior:** Carga del depósito (`0.0%` a `10.0%`)

## 2. Evolución Cronológica de la Curva

* **Q1 – Q2 2023 (`2023.01.13` – `2023.06.12`):** Retroceso inicial breve cerca de `98,460` USD, seguido de un impulso alcista sostenido hasta la zona de `109,500` – `110,073` USD (+10% en 5 meses).
* **H2 2023 – Q1 2024 (`2023.06.12` – `2024.05.16`):** Fase de consolidación lateral controlada entre `108,414` y `112,200` USD, absorbiendo los primeros meses de 2024 sin comprometer las ganancias acumuladas de 2023.
* **Q2 2024 – Q1 2025 (`2024.05.16` – `2025.04.01`):** Expansión fuerte en dos ondas principales (mayo–agosto 2024 hasta `~121,685` USD y septiembre 2024–marzo 2025 alcanzando un máximo local cercano a `126,000` USD).
* **Q2 – Q4 2025 (`2025.04.01` – `2025.12`):** Fase de ajuste/drawdown más prolongada de la serie. La curva retrocede gradualmente desde `~126,000` USD hasta marcar un valle en torno a `116,200` – `116,708` USD hacia finales de 2025 (correspondiente al drawdown máximo del `8.06%` sobre equidad).
* **2026 (`2026.01.14` – `2026.09.21`):** Recuperación limpia y sostenida durante todo el año, superando los máximos previos a mitad de año y cerrando en zona de máximos históricos en torno a `128,320` USD (cierre final en `127,704.44` USD).

## 3. Comportamiento de Equidad y Gestión de Riesgo

* **Alineación Balance (Azul) vs. Patrimonio (Verde):** La curva de equidad acompaña de forma muy ajustada al balance con menor error estándar lineal (`LR Standard Error: 3,247.90` frente a `3,445.82` en v3), reflejando una progresión más suavizada y un **Ratio de Sharpe superior (`3.92`)**.
* **Carga del Depósito (Deposit Load):** Se mantiene extremadamente baja y constante en todo el periodo histórico, por debajo del **`1.0%`** del margen disponible.