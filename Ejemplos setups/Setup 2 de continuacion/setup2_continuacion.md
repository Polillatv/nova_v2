# Especificación de Estrategia: Setup 2 Continuación (NAS100 / US100 - Temporalidad 5M)

## 1. Definición del Rango Base
- **Horario de formación del Rango:** De `02:00 NY` a `07:00 NY`[cite: 16, 17].
- **Niveles del Rango (Porcentaje del rango):**
  - **En Ventas (Bajista):** El `0% INICIO` es el máximo del rango (`High`) y el `100% FINAL` es el mínimo del rango (`Low`), con `50%` en el punto medio[cite: 16].
  - **En Compras (Alcista):** El `0% INICIO` es el mínimo del rango (`Low`) y el `100% FINAL` es el máximo del rango (`High`), con `50%` en el punto medio[cite: 17].

---

## 2. Reglas de Entrada - Setup 2 Continuación (Ventas y Compras)
Busca la continuación tras la estructura de Setup 2 Nacimiento[cite: 19], rompiendo el lado opuesto del rango (`FINAL` del rango)[cite: 16, 17, 19]:

1. **1QR (Primer Quiebre / Absorción o Mitigación de Nacimiento):**
   - Quiebre, absorción o mitigación del lado inicial del rango **con o sin cuerpo de vela**, superando el **0.05% o más**[cite: 16, 17].
   - Se observa el barrido/movimiento `X`, cambio de carácter (`CH`) y quiebre estructural (`BOS`) previo a la ruptura del lado final[cite: 16, 17].
2. **2QR (Segundo Quiebre - Quiebre del Final del Rango):**
   - Posterior al movimiento de nacimiento, el precio quiebra el extremo opuesto (`FINAL` del rango) **con cuerpo de vela** de **0.15% o más**[cite: 16, 17, 19].
3. **1Qe y 2Qe (Dos Quiebres Estructurales Consecutivos + Orden Stop):**
   - Posterior al quiebre `2QR` (`>= 0.15%` con cuerpo de vela), se buscan **2 quiebres estructurales (`1Qe` y `2Qe`)** o detenimientos consecutivos en dirección de la continuación[cite: 16, 17, 19].
   - **Confirmación Premium:** Esperar a que la vela del `2Qe` cierre con cuerpo de vela por debajo (en ventas) o por encima (en compras) y colocar la orden pendiente (`SELL STOP` o `BUY STOP`) en el extremo de esa vela de confirmación[cite: 16, 17, 19].
   - **Composición válida de un Qe:** Puede estar formado por 2 retrocesos clásicos de 2 velas contrarias, 2 detenimientos, o cualquier combinación de ambos (`Retroceso + Detenimiento`, `Detenimiento + Detenimiento`, `Detenimiento + Retroceso`)[cite: 19].

---

## 3. Cálculo Dinámico del Stop Loss (SL)
El nivel del SL se determina midiendo la **distancia porcentual (`d%`) entre el Punto de Entrada (`PE`) y el `FINAL` del rango (`100% FINAL`)**[cite: 16, 17, 19]:

- **SL Conservador (`SL C`):** Si `d% < 0.30%` $\rightarrow$ Colocar SL en el **lateral del inicio del rango** (`0% INICIO`)[cite: 16, 17, 19].
- **SL Moderado (`SL M`):** Si `0.30% <= d% <= 0.50%` $\rightarrow$ Colocar SL en el **50% del rango**[cite: 16, 17, 19].
- **SL Agresivo (`SL A`):** Si `d% > 0.50%` $\rightarrow$ Colocar SL en el **lateral final del rango** (`100% FINAL`)[cite: 16, 17, 19].

---

## 4. Gestión y Desarrollo del Trade (Risk/Reward - RR)
- **Hora de gracia:** Una vez activada la orden Stop, hay **1 hora de gracia**[cite: 19]. Si tras 1 hora no hay momentum, cerrar la operación y volver a esperar una orden Stop en un nuevo quiebre (teniendo siempre en cuenta la entrada original)[cite: 19, 20].
- **En caso de Judas:** Minimizar pérdidas con coberturas o cerrando cerca de `-0.50 RR`[cite: 19].
- **En `+0.50 RR`:** Mover el SL cerca de `-0.25 RR` siguiendo el criterio de los 3 quiebres estructurales de M5[cite: 20].
- **En `+0.80 RR` o más:** Mover el Break Even (`BE`) cerca de `+0.50 RR` considerando altos y bajos, velas o mechas (alternativamente, cerrar en `+0.50 RR` y reingresar con orden Stop si continúa)[cite: 20].
- **En `+1.18 RR`:** Asegurar ganancia moviendo SL mínimamente a `+1.10 RR` (idealmente `+1.15 RR`) cubriendo alto o bajo estructural[cite: 20].
- **Mayor a `+1.20 RR`:** Ir cubriendo altos o bajos estructurales asegurando ganancias[cite: 20].

---

## 5. Reglamento Operativo por Sesión

### Sesión Nueva York (`08:00 NY` a `15:45 NY`)
- **Cierre de sesión:** 5 minutos antes del cierre (`15:40 NY`), si la operación está en `BE` o levemente negativa, cerrar[cite: 18].
- **Apertura Americana (`09:30 NY`):**
  - Si el punto de entrada se presenta cerca de las `09:30 NY`, esperar la vela de apertura y cargar orden por encima o por debajo[cite: 18].
  - Si al llegar a la apertura estoy dentro del mercado en `BE`, cerrar y esperar apertura[cite: 18].
  - Si al llegar a la apertura estoy dentro del mercado y en positivo, colocar `BE` cubriendo alto o bajo en aprox. `-0.25` y dejar correr la apertura, considerando luego las reglas de desarrollo del trade[cite: 18].
- **Noticias:**
  - **Carpeta roja:** Esperar todas las noticias de carpeta roja y ejecutar post-noticias[cite: 18].
  - **FOMC:** Operar únicamente si el Setup se da temprano; estar fuera del mercado como máximo **1 hora y media antes**[cite: 18].

### Sesión Asia (`18:00 NY` a `21:30 NY`)
- **Objetivo:** Sumarse a la expectativa de Setup prevista en NY que por horario no se pudo operar, manteniendo **el mismo rango**[cite: 18].
- **Gestión:** A favor de sostener el Stop Loss; aplica la regla de 1 hora de gracia[cite: 18, 19]. Los domingos suelen ser muy buenos[cite: 18].

---

## 6. Ejemplos Visuales de Referencia (Backtest NAS100 5M)
1. **Venta 22/02/2026:** Tras movimiento inicial y `1QR`, quiebre `2QR` bajista $\rightarrow$ `1 Qe` y `2 Qe` alrededor de las `11:00` $\rightarrow$ Entrada `Sell Stop` con distancia de `0.52%` (`> 0.50%`, asignando `SL A`)[cite: 21].
2. **Compra 28/12/2025:** Tras `QR` / `1 QR` y estructura alcista (`1 Qe` y `2 Qe` alrededor de las `14:00-15:00`) $\rightarrow$ Entrada `Buy Stop` con distancia de `0.21%` (`< 0.30%`, asignando `SL C`)[cite: 22].