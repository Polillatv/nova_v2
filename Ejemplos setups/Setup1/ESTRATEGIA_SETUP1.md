# Especificación de Estrategia: Setup 1 (NAS100 / US100 - Temporalidad 5M)

## 1. Definición del Rango Base
- **Horario de formación del Rango:** De `02:00 NY` a `07:00 NY`.
- **Niveles del Rango (Fibonacci / Porcentaje del rango):**
  - **En Compras (Alcista):** El `0% (INICIO)` es el máximo del rango (`High`) y el `100% (FINAL)` es el mínimo del rango (`Low`). El `50%` es el punto medio.
  - **En Ventas (Bajista):** El `0% (INICIO)` es el mínimo del rango (`Low`) y el `100% (FINAL)` es el máximo del rango (`High`). El `50%` es el punto medio.

---

## 2. Reglas de Entrada - Setup 1 (Compras y Ventas)
La secuencia de activación ocurre **después de las 07:00 NY** y requiere 3 eventos estrictos en orden cronológico:

1. **1QR (Primer Quiebre de Rango):**
   - El precio debe romper el límite del rango (`0% INICIO`: máximo en compras / mínimo en ventas) con **cuerpo de vela** (cierre) superando al menos una distancia del **0.20%** respecto al borde del rango.
2. **1Qe (Primer Quiebre Estructural):**
   - Posterior al `1QR`, el precio realiza un retroceso/pausa y luego quiebra con cuerpo de vela el nuevo máximo (en compras) o mínimo (en ventas) generado tras el `1QR`.
3. **2Qe (Segundo Quiebre Estructural - Gatillo):**
   - Posterior al `1Qe`, ocurre un segundo retroceso/pausa y se forma un nuevo máximo (en compras) o mínimo (en ventas).
   - **Confirmación Premium:** Esperar a que la vela del `2Qe` cierre con cuerpo de vela por encima (compras) o por debajo (ventas) del nivel `2Qe`, y colocar la orden pendiente (`BUY STOP` o `SELL STOP`) en el extremo de esa vela de confirmación.
   - **Composición válida de un Qe:** Puede estar formado por 2 retrocesos clásicos de 2 velas contrarias, 2 detenimientos, o cualquier combinación de ambos (`Retroceso + Detenimiento`, `Detenimiento + Detenimiento`, `Detenimiento + Retroceso`).

---

## 3. Cálculo Dinámico del Stop Loss (SL)
El nivel del SL se determina midiendo la **distancia porcentual (`d%`) entre el Punto de Entrada (`PE`) y el `0% INICIO` del rango**:

- **SL Conservador (`SL C`):** Si `d% < 0.30%` $\rightarrow$ Colocar SL en el **100% FINAL** del rango (extremo opuesto).
- **SL Moderado (`SL M`):** Si `0.30% <= d% <= 0.50%` $\rightarrow$ Colocar SL en el **50%** del rango.
- **SL Agresivo (`SL A`):** Si `d% > 0.50%` $\rightarrow$ Colocar SL en el **0% INICIO** del rango (borde donde ocurrió el `1QR`).

---

## 4. Gestión y Desarrollo del Trade (Risk/Reward - RR)
- **Hora de gracia:** Una vez activada la orden Stop, hay **1 hora de gracia**. Si tras 1 hora no hay momentum, cerrar la operación y volver a esperar una orden Stop en un nuevo quiebre (teniendo siempre en cuenta la entrada original).
- **En caso de Judas (falso quiebre en contra):** Minimizar pérdidas con coberturas o cerrando manualmente cerca de `-0.50 RR`.
- **En `+0.50 RR`:** Mover el SL cerca de `-0.25 RR` siguiendo el criterio de los 3 quiebres estructurales de M5.
- **En `+0.80 RR` o más:** Mover el Break Even (`BE`) cerca de `+0.50 RR` cubriendo altos/bajos, velas o mechas (alternativamente, cerrar en `+0.50 RR` y reingresar con orden Stop si continúa).
- **En `+1.18 RR`:** Asegurar ganancia moviendo SL mínimamente a `+1.10 RR` (idealmente `+1.15 RR`) cubriendo alto o bajo estructural.
- **Mayor a `+1.20 RR`:** Ir haciendo trailing stop cubriendo altos o bajos estructurales.

---

## 5. Reglamento Operativo por Sesión

### Sesión Nueva York (`08:00 NY` a `15:45 NY`)
- **Cierre de sesión:** 5 minutos antes del cierre (`15:40 NY`), si el trade está en `BE` o levemente negativo, cerrar.
- **Apertura Americana (`09:30 NY`):**
  - Si el `PE` aparece cerca de las `09:30 NY`, esperar la vela de apertura y cargar orden por encima/debajo de ella.
  - Si ya estoy dentro del mercado a las `09:30 NY` en `BE`, cerrar y esperar la apertura.
  - Si ya estoy dentro del mercado a las `09:30 NY` en positivo, mover `BE` cubriendo alto/bajo en aprox. `-0.25 RR` y dejar correr la apertura.
- **Noticias:**
  - **Carpeta roja:** Esperar a que pasen todas las noticias antes de ejecutar.
  - **FOMC:** Operar únicamente si el Setup se da temprano y estar fuera del mercado como máximo **1 hora y 30 minutos antes** del anuncio.

### Sesión Asia (`18:00 NY` a `21:30 NY`)
- **Objetivo:** Sumarse a la expectativa del Setup prevista en NY que por horario no se pudo operar, manteniendo **exactamente el mismo rango** (`02:00 - 07:00 NY`).
- **Gestión:** Se opera a favor de sostener el Stop Loss; aplica la misma regla de 1 hora de gracia. Los domingos suelen tener mejor comportamiento.

---

## 6. Ejemplos Visuales de Referencia (Backtest NAS100 5M)
Todos los ejemplos gráficos adjuntos ilustran ejecuciones con **SL Agresivo (`SL A`)** debido a que la distancia entre el `PE` y el `0% INICIO` superó el `0.50%`:
1. **Compra 29/09/2026:** Rango 02:00-07:00 $\rightarrow$ Quiebre `QR` al alza $\rightarrow$ `1 Qe` $\rightarrow$ `2 Qe` alrededor de las 11:00 $\rightarrow$ Entrada Buy Stop con distancia de `0.54%` respecto al `0% INICIO` $\rightarrow$ Se asigna `SL A` en el borde superior del rango.
2. **Venta 09/08/2026:** Rango 02:00-07:00 $\rightarrow$ Quiebre `QR` a la baja $\rightarrow$ `1 Qe` $\rightarrow$ `2 Qe` alrededor de las 10:00 $\rightarrow$ Entrada Sell Stop con distancia de `0.89%` respecto al `0% INICIO` $\rightarrow$ Se asigna `SL A` en el borde inferior del rango.
3. **Compra 26/04/2026:** Rango 02:00-07:00 $\rightarrow$ Quiebre `QR` al alza $\rightarrow$ `1 Qe` a las 09:45 $\rightarrow$ `2 Qe` a las 11:00 $\rightarrow$ Entrada con distancia de `0.72%` $\rightarrow$ Se asigna `SL A`.
4. **Compra 13/04/2026:** Rango 02:00-07:00 $\rightarrow$ Quiebre `QR` al alza $\rightarrow$ `1 Qe` a las 09:15 $\rightarrow$ `2 Qe` a las 09:45 $\rightarrow$ Entrada con distancia de `0.715%` (`180.0 pts`) $\rightarrow$ Se asigna `SL A` (ejemplo con ratio Riesgo/Beneficio proyectado de `8.34`).