# Especificación de Estrategia: Setup 3 - NO OPERABLE (NO SE OPERA)

## 1. Regla Principal
- **Estado:** **NO OPERABLE / NO SE OPERA** (regla de exclusión / filtro de no-operativa).
- **Propósito:** Identificar comportamientos del precio respecto al `RANGO` en los que **no se deben ejecutar entradas** ni buscar setups operativos en esa dirección.

---

## 2. Condiciones de Identificación del Setup 3

### Escenario A: Ejemplo Lineal Ventas (Setup 3 No Operable)
- El precio interactúa con el `RANGO`: **"SALE POR UN LADO"** (rompe/sale por el límite inferior del rango) y luego **"SALE POR EL OTRO"** (rompe/sale por el límite superior del rango).
- Tras salir por ambos lados del rango, el precio **"RETOMA DIRECCIÓN CONTRARIA"** (gira a la baja retomando la dirección contraria al impulso alcista previo).
- **Acción:** **NO SE OPERA**.

### Escenario B: Ejemplo Lineal Compras (Setup 3 No Operable)
- El precio interactúa con el `RANGO`: **"SALE POR UN LADO"** (rompe/sale por el límite superior del rango) y luego **"SALE POR EL OTRO"** (rompe/sale por el límite inferior del rango).
- Tras salir por ambos lados del rango, el precio **"RETOMA DIRECCIÓN CONTRARIA"** (gira al alza retomando la dirección contraria a la caída previa).
- **Acción:** **NO SE OPERA**.

---

## 3. Lógica Resumen para Código / Automatización
- **Patrón de exclusión (`is_setup3_no_operable = true`):**
  1. Se forma el `RANGO` base.
  2. El precio vulnera/sale por un extremo del rango (`SALE POR UN LADO`) y posteriormente vulnera/sale por el extremo opuesto (`SALE POR EL OTRO`).
  3. El precio gira y retoma la dirección contraria (`RETOMA DIRECCIÓN CONTRARIA`).
- **Restricción:** Bloquear/omitir señales de entrada cuando se detecte este patrón de barrido bilateral y giro en dirección contraria.
