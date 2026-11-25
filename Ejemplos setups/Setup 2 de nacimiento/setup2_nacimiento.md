# Especificación de Estrategia: Setup 2 Nacimiento (NAS100 / US100 - Temporalidad 5M)

## 1. Definición del Rango Base
- **Horario de formación del Rango:** De `02:00 NY` a `07:00 NY`[cite: 10, 11].
- **Niveles del Rango (Porcentaje del rango):**
  - **En Ventas (Bajista):** El `0% (INICIO)` es el máximo del rango (`High`) y el `100% (FINAL)` es el mínimo del rango (`Low`)[cite: 10]. Se marcan niveles intermedios en `50%` y `75%` hacia el interior del rango[cite: 10].
  - **En Compras (Alcista):** El `0% (INICIO)` es el mínimo del rango (`Low`) y el `100% (FINAL)` es el máximo del rango (`High`)[cite: 11]. Se marcan niveles intermedios en `50%` y `75%` hacia el interior del rango[cite: 11].

---

## 2. Reglas de Entrada - Setup 2 Nacimiento (Ventas y Compras)
La secuencia ocurre **a partir de las 07:00 NY** y busca una reversión/reincorporación al rango con estructura de cambio de carácter (`CH`) y quiebre estructural (`BOS`):

1. **1QR (Primer Quiebre de Rango / Absorción o Mitigación):**
   - Quiebre, absorción o mitigación del límite del rango (`0% INICIO`: máximo en ventas / mínimo en compras) **con o sin cuerpo de vela**, superando una distancia de **0.05% o más** desde el borde del rango[cite: 10, 11, 13].
2. **Creación de `CH` (Change of Character):**
   - Tras el `1QR` (y un movimiento/barrida marcado como `X` en el esquema), el precio gira en dirección contraria creando un `CH` que reincorpora o apunta hacia el interior del rango[cite: 10, 11, 13].
3. **Reacción al `50%` y Gatillo en `75%` (`BOS` + Orden Stop):**
   - Se observa un retroceso/reacción hacia el `50%` del rango (frecuentemente coincidente con zonas u Order Blocks / `OB`) y posterior quiebre estructural (`BOS`) con intención de atravesar el rango[cite: 10, 11, 13].
   - **Punto de Entrada (`PE`):** Colocar orden pendiente (`SELL STOP` por debajo o `BUY STOP` por encima) en la zona del **75% del rango** (tras el `BOS`) buscando atravesar el rango[cite: 10, 11, 13].

---

## 3. Cálculo Dinámico del Stop Loss (SL)
El nivel del SL se determina midiendo la **distancia porcentual (`d%`) entre el inicio del rango (`0% INICIO`) y el extremo protegido del `CH`** (alto del `CH` en ventas / bajo del `CH` en compras)[cite: 10, 11, 13]:

- **SL Conservador (`SL C`):** Si `d% < 0.15%` $\rightarrow$ Colocar SL cubriendo el alto o bajo del `CH`[cite: 13].
- **SL Moderado (`SL M`):** Si `0.15% <= d% <= 0.25%` $\rightarrow$ Colocar SL cubriendo algún alto o bajo interno, gap, mecha o vela entera posterior al movimiento del alto o bajo del `CH`[cite: 13].
- **SL Agresivo (`SL A`):** Si `d% > 0.25%` $\rightarrow$ Colocar SL agresivo según el criterio del esquema cuando la salida/distancia supera el `0.25%`[cite: 10, 11, 13].

---

## 4. Reglamento Operativo por Sesión

### Sesión Nueva York (`08:00 NY` a `15:45 NY`)
- **Cierre de sesión:** 5 minutos antes del cierre (`15:40 NY`), si la operación está en `BE` o levemente negativa, cerrar[cite: 12].
- **Apertura Americana (`09:30 NY`):**
  - Si el punto de entrada aparece cerca de las `09:30 NY`, esperar la vela de apertura y cargar orden por encima o por debajo[cite: 12].
  - Si al llegar a la apertura ya estoy dentro del mercado en `BE`, cerrar y esperar la apertura[cite: 12].
  - Si al llegar a la apertura ya estoy dentro del mercado y en positivo, colocar `BE` cubriendo alto o bajo en aprox. `-0.25` y dejar correr la apertura, aplicando luego las reglas de desarrollo del trade del setup[cite: 12].
- **Noticias:**
  - **Carpeta roja:** Esperar todas las noticias de carpeta roja y ejecutar post-noticias[cite: 12].
  - **FOMC:** Operar únicamente si el Setup se da temprano; estar fuera del mercado como máximo **1 hora y media antes**[cite: 12].

### Sesión Asia (`18:00 NY` a `21:30 NY`)
- **Objetivo:** Sumarse a la expectativa de Setup prevista en NY que por horario no se pudo operar, manteniendo **exactamente el mismo rango** (`02:00 - 07:00 NY`)[cite: 10, 11, 12].
- **Gestión:** A favor de sostener el Stop Loss; mantiene la regla de hora de gracia[cite: 12]. Los domingos suelen tener un comportamiento favorable[cite: 12].

---

## 5. Ejemplos Visuales de Referencia (Backtest NAS100 5M)
1. **Venta 16/08/2026 (`SL C`):** Rango `02:00-07:00` $\rightarrow$ `QR` al alza con distancia de `0.10%` (`< 0.15%`) $\rightarrow$ `CH` y `BOS` a la baja $\rightarrow$ Entrada `Sell Stop` tras quiebre estructural con `SL C` cubriendo el alto del `CH`[cite: 14].
2. **Compra 14/06/2026 (`SL A`):** Rango `02:00-07:00` $\rightarrow$ `QR` a la baja con distancia de `0.73%` (`> 0.25%`) $\rightarrow$ `CH` alcista y reacción/quiebre al alza $\rightarrow$ Entrada `Buy Stop` con `SL A`[cite: 15].