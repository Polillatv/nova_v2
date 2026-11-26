# Análisis de la Curva de Balance y Patrimonio - Nova_Bot_v3.2 (`Nova_Bot_v3_2`)

## 1. Metadatos del Gráfico (Strategy Tester - Graph)

* **Plataforma / Servidor:** MetaTrader 5 (Pepperstone-Demo)
* **Asesor Experto (EA):** `Nova_Bot_v3_2` (v3.2)
* **Símbolo / Temporalidad:** `NAS100`, `M5`
* **Periodo Evaluado (Eje X):** `2023.01.11` hasta `2026.10.12` (~3 años y 9 meses)
* **Rango Vertical Balance / Patrimonio (Eje Y):** `96,624` a `130,660` USD (Capital inicial: `100,000.00` USD)
* **Panel Inferior:** Carga del depósito (`0.0%` a `10.0%`)

## 2. Evolución Cronológica de la Curva

* **Q1 – Q2 2023 (`2023.01.11` – `2023.06.09`):** Retroceso inicial breve cerca de `98,244` USD, seguido de un fuerte impulso alcista que lleva el balance hacia la zona de `109,590` – `110,200` USD (+10% en 5 meses).
* **H2 2023 – Q1 2024 (`2023.06.09` – `2024.04.22`):** Fase de consolidación lateral controlada entre `107,969` y `112,831` USD, absorbiendo los primeros meses de 2024 en torno a `109,590` USD sin comprometer el capital base.
* **Q2 2024 – Q1 2025 (`2024.06.03` – `2025.02.24`):** Expansión sostenida en dos ondas principales (junio–agosto 2024 hasta `~120,935` USD y septiembre 2024–febrero 2025 alcanzando un pico local cercano a `125,798` USD).
* **Q2 – Q4 2025 (`2025.02.24` – `2025.12`):** Fase de ajuste/drawdown más prolongada del backtest. La curva desciende gradualmente desde `~125,798` USD hasta marcar un valle en torno a `116,073` USD hacia finales de 2025 (correspondiente al drawdown máximo más bajo de toda la serie v3: **`7.72%`** sobre equidad y **`7.32%`** sobre balance).
* **2026 (`2026.01.15` – `2026.10.12`):** Recuperación sostenida en el primer semestre (`116,073` $\rightarrow$ `122,556` USD) y aceleración marcada en Q3–Q4, superando los máximos históricos previos para cerrar en torno a `127,419` USD (cierre exacto en `126,488.50` USD).

## 3. Comportamiento de Equidad y Gestión de Riesgo

* **Menor Error Estándar y Menor Drawdown de la Serie v3:** La curva presenta el menor `LR Standard Error` (`3,209.01`) y el menor drawdown relativo tanto en balance (`7.32%`) como en equidad (`7.72%`) de las tres iteraciones de `v3`, manteniendo una correlación lineal de `0.90`.
* **Carga del Depósito (Deposit Load):** Extremadamente baja y uniforme durante todo el histórico, manteniéndose siempre por debajo del **`1.0%`** del margen disponible.