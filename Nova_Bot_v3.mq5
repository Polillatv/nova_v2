//+------------------------------------------------------------------+
//|                                                  Nova_Bot_v3.mq5 |
//|           Estrategia Nova - Edición Fiel Manual v3.15            |
//|   Calibración Fiel Backtest Manual + Bullfy + DST Auto + S1/2/3  |
//|   Fix 1QR!=1Qe + Carryover 24/7 + Gracia SL -0.25R + Swing M5    |
//+------------------------------------------------------------------+
#property copyright "Estrategia Nova"
#property version   "3.15"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| 1. ENUMERACIONES Y PARÁMETROS CONFIGURABLES (INPUTS)             |
//+------------------------------------------------------------------+
enum ENUM_QE_PB_MODE
  {
   PB_MODE_COUNTER_OR_PAUSE = 0, // Fiel Nova: vela contraria o detenimiento sin nuevo extremo
   PB_MODE_LEGACY           = 1  // Modo simple: vela sin superar extremo previo
  };

enum ENUM_TRAIL_MODE
  {
   TRAIL_NOVA_SWING = 0,         // Estándar Nova v3.10 (+0.50/-0.25, +0.80/+0.50, +1.80/+1.15, >=2.00 swings)
   TRAIL_OPTIMIZED  = 1,         // Optimizado (+0.65/BE, +1.00/+0.50, +1.50/+1.00, >=2.00 swings)
   TRAIL_ATR_SWING  = 2,         // Activo Qe v3.13 (escalones 1.2/1.5/1.8R + swings >=1.5R + ATR fallback)
   TRAIL_M5_SWING   = 3          // Fiel Manual v3.15 (-0.25R inicial + Swings Estructurales M5 post-entrada)
  };

input group "=== 1. HORARIOS, DST Y GRÁFICO ==="
input bool   InpAutoDST               = true;            // Calcular DST NY y Bróker automáticamente
input int    InpBrokerWinterOffsetUTC = 2;               // Offset UTC invierno del bróker (Pepperstone = +2)
input bool   InpBrokerUsesEUDST       = true;            // Bróker usa horario verano UE (último dom mar/oct)
input int    InpServerOffsetFromNY    = 7;               // Offset manual (solo si InpAutoDST = false)
input int    InpRangeStartHour        = 2;               // Hora inicio rango (NY)
input int    InpRangeStartMin         = 0;               // Minuto inicio rango (NY)
input int    InpRangeEndHour          = 7;               // Hora fin rango (NY)
input int    InpRangeEndMin           = 0;               // Minuto fin rango (NY)
input int    InpSessionStartHour      = 8;               // Inicio ventana operativa NY (caja amarilla 08:00)
input int    InpSessionStartMin       = 0;               // Minuto inicio ventana operativa NY
input int    InpLastEntryHourNY       = 15;              // Hora límite nuevas entradas NY
input int    InpLastEntryMinNY        = 0;               // Minuto límite nuevas entradas NY
input int    InpSessionEndHour        = 15;              // Hora fin gestión NY
input int    InpSessionEndMin         = 45;              // Minuto fin gestión NY
input bool   InpEnableAsiaSession     = false;           // Habilitar sesión Asia (18:00 - 21:30 NY)
input bool   InpAllowSundayAsia       = true;            // En domingo Asia usar último rango válido (viernes)
input int    InpAsiaStartHour         = 18;              // Hora inicio entradas Asia (NY)
input int    InpAsiaStartMin          = 0;               // Minuto inicio entradas Asia (NY)
input int    InpAsiaLastEntryHour     = 21;              // Hora límite entradas Asia (NY)
input int    InpAsiaLastEntryMin      = 30;              // Minuto límite entradas Asia (NY)
input int    InpAsiaEndHour           = 23;              // Hora fin gestión Asia (NY)
input int    InpAsiaEndMin            = 45;              // Minuto fin gestión Asia (NY)
input bool   InpAsiaAllowIfNYTraded   = false;           // Permitir operar en Asia si ese setup ya operó en NY
input color  InpRangeColor            = clrMediumPurple; // Color caja de rango
input color  InpLinesColor            = clrBlack;        // Color líneas 0% y 100%

input group "=== 2. RIESGO Y CUMPLIMIENTO PROP FIRM (BULLFY) ==="
input double InpRiskPercent               = 0.50;        // Riesgo por operación (% Balance)
input bool   InpSkipIfMinLotExceedsRisk   = true;        // Abortar si lote mínimo supera riesgo máximo
input double InpMaxAllowedRiskPct         = 0.75;        // Riesgo máximo tolerado si aplica lote mínimo (%)
input bool   InpUseDailyDDGuard           = true;        // Activar freno de pérdida diaria máxima
input double InpMaxDailyLossPct           = 3.50;        // Pérdida máxima diaria para bloquear nuevas entradas (%)
input bool   InpUseNewsFilter             = true;        // Activar filtro de noticias rojas (Forex Factory)
input string InpNewsCurrency              = "USD";       // Divisas a filtrar (ej. "USD" o "USD,ALL")
input int    InpNewsMinsBefore            = 5;           // Minutos ventana ANTES noticia roja (Bullfy: 5)
input int    InpNewsMinsAfter             = 5;           // Minutos ventana DESPUÉS noticia roja (Bullfy: 5)
input bool   InpKeepPreExistingPendingInNews = false;    // false = pausar pendientes antes de noticia sin matar setup
input bool   InpUseFOMCRule               = true;        // Estar fuera 1h 30m antes de anuncios FOMC
input int    InpFOMCExitMinsBefore        = 90;          // Minutos antes de FOMC para cerrar/bloquear
input bool   InpLoadTesterNewsCSV         = true;        // En Backtest leer Common\Files\ff_news_history.csv si existe

input group "=== 3. SETUPS Y REGLAS OPERATIVAS ==="
input bool            InpEnableSetup1          = true;   // Activar Setup 1
input bool            InpEnableSetup2Nac       = true;   // Activar Setup 2 Nacimiento
input bool            InpEnableSetup2Cont      = true;   // Activar Setup 2 Continuación
input bool            InpS2C_InvalidatesS1     = true;   // Si se activa S2 Continuación, invalidar Setup 1
input bool            InpEnableSetup3Filter    = true;   // Activar Filtro Setup 3 (barrido bilateral)
input bool            InpObserveFrom7AM        = false;  // false = Evaluar estructura desde 08:00 NY (caja amarilla)
input bool            InpArmPre8AMTriggerAt8AM = false;  // Armar a las 08:00 NY si se observó señal pre-08:00
input ENUM_QE_PB_MODE InpQePBMode              = PB_MODE_COUNTER_OR_PAUSE; // Modo de conteo de retrocesos Qe
input int             InpPullbackCandles       = 1;      // Velas contrarias o detenimiento para fijar 1Qe/2Qe (TV: 1)
input bool            InpDirect2QeEntry        = true;   // true = Stop directo sobre el nivel 2Qe (fiel capturas TV)
input double          InpEntryBufferPts        = 1.5;    // Buffer entrada Stop en puntos del índice
input double          InpSLBufferPts           = 2.0;    // Buffer de SL en puntos del índice
input bool            InpS1_AllowDeepPullback  = true;   // Permitir retroceso profundo en Setup 1 antes de 1Qe
input bool            InpS2C_AllowDeepPullback = true;   // Permitir retroceso profundo en Setup 2 Cont
input bool            InpFilter930Open         = true;   // Gestionar apertura 09:30 NY (esperar vela si PE cae ~09:30)
input bool            InpClose1540Rule         = false;  // false = No cerrar abiertas en 15:40 NY; monitorear SL en Asia
input bool            InpProtectAtAsiaEnd      = true;   // Asegurar BE+ al cerrar Asia / ir a dormir
input int             InpBedtimeProtectHour    = 21;     // Hora NY para proteger en BE+ nocturno
input int             InpBedtimeProtectMin     = 30;     // Minuto NY para proteger en BE+ nocturno
input double          InpBedtimeLockRR         = 0.05;   // Nivel RR mínimo a asegurar antes de dormir (+0.05R)
input bool            InpAvoid10AMHour         = false;  // Evitar nuevas señales de 10:00 a 10:59 NY
input int             InpGracePeriodMins       = 60;     // Minutos para mitigar SL si el precio aún no despegó
input bool            InpGraceCloseMarket      = false;  // false = Mitigar SL a -0.25R a los 60m (sin cerrar a mercado)
input double          InpGraceMitigateSL_RR    = -0.25;  // Nivel SL objetivo (RR) al cumplir 60m (-0.25R)
input double          InpGraceMinRR            = 0.20;   // [Solo si GraceCloseMarket=true] RR mínimo a los 60m

input group "=== 4. UMBRALES SETUP 1, 2 CONTINUACIÓN Y SETUP 3 ==="
input double InpS1_1QR_Pct              = 0.20;          // Setup 1: Quiebre inicial 1QR (%)
input double InpS2C_2QR_Pct             = 0.15;          // Setup 2 Cont: Quiebre opuesto 2QR (%)
input bool   InpS2C_RequireS2NStructure = false;         // Exigir CH previo antes de habilitar S2C
input double InpCont_SL_AgresPct        = 0.50;          // Distancia > X% para SL Agresivo
input double InpCont_SL_ModMinPct       = 0.30;          // Distancia >= X% para SL Moderado
input double InpS3_MinOutPct            = 0.05;          // Salida mínima del rango (%) en cada extremo para Setup 3
input bool   InpS3_RequireBodyBreak     = true;          // Exigir cierre con cuerpo fuera de ambos lados en Setup 3
input bool   InpS3_RequireMidCross      = true;          // Exigir cruce de 50% con cuerpo al retomar dirección contraria

input group "=== 5. UMBRALES SETUP 2 NACIMIENTO ==="
input double InpS2N_1QR_Pct             = 0.05;          // Setup 2 Nac: Quiebre/absorción mínima (%)
input double InpS2N_EntryLevelPct       = 75.0;          // Nivel de entrada dentro del rango (%)
input bool   InpS2N_Strict50BOS         = true;          // Exigir reacción ~50% + BOS antes de colocar orden
input double InpS2N_ReactionZonePct     = 45.0;          // Profundidad mínima dentro del rango (%) para validar reacción
input double InpS2N_SL_AgresPct         = 0.25;          // Distancia > X% para SL Agresivo
input double InpS2N_SL_ModMinPct        = 0.15;          // Distancia >= X% para SL Moderado
input double InpS2N_SL_AgresSweepFrac   = 0.50;          // Fracción de barrido externo (0% <-> Extremo CH) para SL A
input int    InpS2N_MaxTradesPerDay     = 1;             // Máximo de trades Setup 2 Nacimiento por día
input bool   InpS2N_AvoidOpen10AM       = false;         // Bloquear barridos 1QR S2 Nac entre 09:25 y 09:55 NY

input group "=== 6. GESTIÓN, TRAILING HÍBRIDO, JUDAS Y ABLACIÓN ==="
input bool            InpExit_Grace                 = true;      // Activar mitigación / gestión de los 60 minutos
input bool            InpExit_Open930               = true;      // Activar gestión apertura 09:30 NY
input bool            InpExit_Trailing              = true;      // Activar trailing por RR y swings
input bool            InpExit_EndOfDay              = true;      // Activar reglas fin de jornada / protección nocturna
input ENUM_TRAIL_MODE InpTrailModeQe                = TRAIL_M5_SWING;   // Modo de trailing para Setup 1 y Setup 2 Cont (Motor Qe)
input ENUM_TRAIL_MODE InpTrailModeS2N               = TRAIL_M5_SWING;   // Modo de trailing para Setup 2 Nacimiento
input double          InpTrail_Step1_TrigRR         = 0.50;      // Escalón 1 (común): activar al llegar a +X RR
input double          InpTrail_Step1_SL_RR          = -0.25;     // Escalón 1 (común): mover SL a X RR (-0.25R)
input double          InpManualSwing_StartRR        = 0.80;      // [M5_SWING] Desde +X RR activar trailing por swing M5
input bool            InpManualSwing_RequireBOS     = true;      // [M5_SWING] Exigir BOS del swing antes de +2.0R
input double          InpSoftFloor_TrigRR           = 1.25;      // [M5_SWING v3.15] Piso suave: activar a +X RR
input double          InpSoftFloor_SL_RR            = 0.60;      // [M5_SWING v3.15] Piso suave: SL a +X RR
input double          InpManualSwing_NoBOSFromRR    = 1.00;      // [M5_SWING v3.15] Desde +X RR aceptar fractal M5 sin exigir BOS
input bool            InpGraceMicroSwing            = false;     // [v3.15] Micro-swing fBars=1 a los 60m (false = mantener SL)
input double          InpManualSwing_FreeAboveRR    = 2.00;      // [M5_SWING] Desde +X RR aceptar todo fractal M5 post-entrada
input bool            InpManualSwing_UseATRFallback = true;      // [M5_SWING] Respaldo ATR en impulsos verticales >=2R sin swing
input double          InpTrail_Step2_TrigRR         = 0.80;      // [Legacy/ATR] Escalón 2: activar al llegar a +X RR
input double          InpTrail_Step2_SL_RR          = 0.50;      // [Legacy/ATR] Escalón 2: mover SL a +X RR (+0.50R)
input double          InpTrail_Step3_TrigRR         = 1.80;      // [NOVA_SWING] Escalón 3: activar al llegar a +X RR (+1.80R)
input double          InpTrail_Step3_SL_RR          = 1.15;      // [NOVA_SWING] Escalón 3: mover SL a +X RR (+1.15R)
input double          InpTrail_SwingStartRR         = 2.00;      // [NOVA_SWING] Desde +X RR seguir swings fractales M5
input double          InpTrailX_Step3_TrigRR        = 1.20;      // [ATR_SWING] Escalón extra A: activar a +X RR
input double          InpTrailX_Step3_SL_RR         = 0.70;      // [ATR_SWING] Escalón extra A: SL a +X RR
input double          InpTrailX_Step4_TrigRR        = 1.50;      // [ATR_SWING] Escalón extra B: activar a +X RR
input double          InpTrailX_Step4_SL_RR         = 1.00;      // [ATR_SWING] Escalón extra B: SL a +X RR
input double          InpTrailX_Step5_TrigRR        = 1.80;      // [ATR_SWING] Escalón extra C: activar a +X RR
input double          InpTrailX_Step5_SL_RR         = 1.30;      // [ATR_SWING] Escalón extra C: SL a +X RR
input double          InpTrailX_SwingStartRR        = 1.50;      // [ATR_SWING] Desde +X RR seguir swings fractales M5
input double          InpTrailX_ATRStartRR          = 1.50;      // [ATR_SWING] Desde +X RR habilitar protección ATR
input int             InpTrailX_ATRPeriod           = 14;        // [ATR_SWING] Período ATR (M5)
input double          InpTrailX_ATRMult             = 2.0;       // [ATR_SWING] Multiplicador ATR (k x ATR)
input bool            InpTrailX_ATROnlyWithoutSwing = true;      // [ATR_SWING] true = ATR solo si aún no hay swing sobre el piso
input bool            InpTrailX_ATROnBarClose       = true;      // [ATR_SWING] true = evaluar ATR al cierre M5 (sin mechas tick)
input int             InpSwingFractalBars           = 2;         // Velas a cada lado para swing fractal M5
input int             InpSwingLookbackBars          = 40;        // Máximo de velas M5 para buscar swings
input bool            InpEnableJudasCut             = false;     // Cortar en contra cerca de -0.50 RR (Judas)
input double          InpJudasTriggerRR             = -0.50;     // Umbral RR negativo para corte Judas
input double          InpTP_R_S1                    = 5.0;       // TP Setup 1 (múltiplo de R)
input double          InpTP_R_S2C                   = 5.0;       // TP Setup 2 Continuación (múltiplo de R)
input double          InpTP_R_S2N                   = 4.0;       // TP Setup 2 Nacimiento (múltiplo de R)

input group "=== 7. TRAZA DE DIAGNÓSTICO ==="
input bool   InpDebugTrace              = false;         // Escribir CSV de decisiones (Common\Files)
input string InpTraceTag                = "";            // Etiqueta del CSV
input bool   InpTraceBars               = true;          // Registrar cambio de estado por vela

//+------------------------------------------------------------------+
//| 2. CONSTANTES, ESTRUCTURAS Y ESTADO GLOBAL                       |
//+------------------------------------------------------------------+
#define MAGIC_S1      202601
#define MAGIC_S2_NAC  202602
#define MAGIC_S2_CONT 202603

struct NewsEvent
  {
   datetime timeNY;
   string   title;
   string   currency;
   bool     isFOMC;
  };

enum ENUM_QE_STAGE
  {
   QE_INACTIVE = 0,
   QE_WAIT_1QE_PB,
   QE_WAIT_1QE_BRK,
   QE_WAIT_2QE_PB,
   QE_WAIT_2QE_BRK,
   QE_READY_ORDER,
   QE_ORDER_ACTIVE,
   QE_IN_TRADE,
   QE_FINISHED
  };

struct QeMachine
  {
   ENUM_QE_STAGE stage;
   int           dir;            // 1 = Compra, -1 = Venta
   double        extreme;
   double        lvl1Qe;
   double        lvl2Qe;
   double        pendingEntry;
   int           pbCount;
   int           tradesToday;
   double        initRisk;
   double        maxRRReached;
   string        slType;
   bool          open930Done;
   bool          graceDone;
   bool          pausedByNews;
   bool          waitOpen930;
   bool          orderInAsia;
  };

struct CarryoverPos
  {
   ulong         ticket;
   ulong         magic;
   string        setupName;
   double        initRisk;
   double        maxRRReached;
   bool          open930Done;
   bool          graceDone;
   bool          inAsia;
  };

enum ENUM_S2N_STAGE
  {
   S2N_WAIT_1QR = 0,
   S2N_WAIT_CH,
   S2N_WAIT_50_REACTION,
   S2N_WAIT_BOS,
   S2N_READY_ORDER,
   S2N_ORDER_ACTIVE,
   S2N_IN_TRADE,
   S2N_FINISHED
  };

CTrade         trade;

//--- Rango Diario
double         g_RangeHigh            = 0.0;
double         g_RangeLow             = 0.0;
double         g_RangeMid             = 0.0;
double         g_RangePct             = 0.0;
double         g_LastValidRangeHigh   = 0.0;
double         g_LastValidRangeLow    = 0.0;
bool           g_RangeReady           = false;
bool           g_RangeFinalized       = false;

//--- Calendario de Noticias
NewsEvent      g_NewsList[];
datetime       g_LastNewsFetch        = 0;
datetime       g_LastNewsAttempt      = 0;
string         g_NewsStatus           = "Iniciando...";
string         g_NextNewsInfo         = "Sin eventos próximos";

//--- Control de Jornada, Riesgo Diario y Máquinas de Estado
int            g_ActiveDayKey         = -1;
datetime       g_LastBarTime          = 0;
bool           g_SessionBlockedS3     = false;
bool           g_FOMCBlockedNY        = false;
bool           g_DailyDDBreached      = false;
bool           g_HistorySynced        = false;
bool           g_AsiaActivatedToday   = false;
double         g_DayStartBalance      = 0.0;
double         g_DayStartEquity       = 0.0;

QeMachine      g_S1;
QeMachine      g_S2C;
CarryoverPos   g_CarryPos[];

//--- Estado Setup 2 Nacimiento
ENUM_S2N_STAGE g_S2NStage             = S2N_WAIT_1QR;
int            g_S2NDir               = 0;
double         g_S2NExtreme           = 0.0;
double         g_S2NProtectedExtreme  = 0.0;
double         g_S2NXPivot            = 0.0;
double         g_S2NCHLevel           = 0.0;
bool           g_S2NXPivotSet         = false;
bool           g_S2NCHLockedFromX     = false;
bool           g_S2NPullbackSeen      = false;
bool           g_S2NReached50         = false;
double         g_S2NBOSHigh           = 0.0;
double         g_S2NBOSLevel          = 0.0;
double         g_S2NInternalRef       = 0.0;
double         g_S2NInitRisk          = 0.0;
double         g_S2NMaxRRReached      = 0.0;
string         g_S2NSLType            = "";
bool           g_S2NOpen930Done       = false;
bool           g_S2NGraceDone         = false;
bool           g_S2NPausedByNews      = false;
bool           g_S2NWaitOpen930       = false;
bool           g_S2NOrderInAsia       = false;
int            g_S2NTradesToday       = 0;

//--- Rastreo Estructura / Setup 2 Continuación / Setup 3
bool           g_HadSideBreakout      = false;
int            g_FirstBreakDir        = 0;
bool           g_S2NStructureConfirmed= false;
int            g_S2NStructDir         = 0;
bool           g_Setup3Triggered      = false;
bool           g_HitHigh              = false;
bool           g_HitLow               = false;
int            g_S3SecondSide         = 0;

//--- Horario / Traza / Caché Visual
int            g_NYOffsetSec          = 0;
int            g_LastOffsetDayKey     = -1;
int            g_TraceHandle          = INVALID_HANDLE;
int            g_TraceSeq             = 0;
string         g_TraceFile            = "";
string         g_LastStateSig         = "";
bool           g_RangeLogged          = false;
datetime       g_LastScenarioBarDrawn = 0;
string         g_HudCacheText[10];
color          g_HudCacheColor[10];

//+------------------------------------------------------------------+
//| 3. TRAZA DE DIAGNÓSTICO Y UTILIDADES                             |
//+------------------------------------------------------------------+
string Fmt(double v)
  {
   if(v == 0.0) return "";
   return DoubleToString(v, 5);
  }

string Sanitize(string s)
  {
   StringReplace(s, ";", ",");
   StringReplace(s, "\r", " ");
   StringReplace(s, "\n", " ");
   return s;
  }

double IndexPtsToPrice(double indexPts)
  {
   double priceOffset = 0.0;
   if(_Digits <= 2)
      priceOffset = indexPts;
   else
     {
      double mult = (_Digits == 3 || _Digits == 5) ? 10.0 : 1.0;
      priceOffset = indexPts * _Point * mult;
     }
   return MathMax(_Point, NormalizeDouble(priceOffset, _Digits));
  }

void TraceInit()
  {
   g_TraceHandle  = INVALID_HANDLE;
   g_LastStateSig = "";
   g_RangeLogged  = false;
   g_TraceSeq     = 0;

   if(!InpDebugTrace) return;

   string tag = InpTraceTag;
   if(tag == "")
      tag = _Symbol + "_" + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES);
   StringReplace(tag, " ", "_");
   StringReplace(tag, ":", "-");
   StringReplace(tag, ".", "-");
   StringReplace(tag, "\\", "-");
   StringReplace(tag, "/", "-");
   g_TraceFile = "Nova_v3_trace_" + tag + ".csv";

   g_TraceHandle = FileOpen(g_TraceFile, FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON, ';');
   if(g_TraceHandle == INVALID_HANDLE)
     {
      Print("NOVA v3: no se pudo crear la traza ", g_TraceFile, " (err ", GetLastError(), ")");
      return;
     }

   FileWrite(g_TraceHandle, "seq", "srv_time", "ny_time", "event", "setup", "dir",
             "p1", "p2", "p3", "p4", "note");
   Print("NOVA v3 traza activa -> Common\\Files\\", g_TraceFile);
  }

void TraceClose()
  {
   if(g_TraceHandle == INVALID_HANDLE) return;
   FileFlush(g_TraceHandle);
   FileClose(g_TraceHandle);
   g_TraceHandle = INVALID_HANDLE;
  }

void TraceEv(string ev, string setup, int dir,
             double p1, double p2, double p3, double p4, string note)
  {
   if(g_TraceHandle == INVALID_HANDLE) return;

   g_TraceSeq++;
   datetime srv = TimeCurrent();
   datetime ny  = srv - g_NYOffsetSec;
   string dirTxt = (dir > 0) ? "BUY" : ((dir < 0) ? "SELL" : "");

   FileWrite(g_TraceHandle,
             IntegerToString(g_TraceSeq),
             TimeToString(srv, TIME_DATE|TIME_SECONDS),
             TimeToString(ny,  TIME_DATE|TIME_SECONDS),
             ev, setup, dirTxt,
             Fmt(p1), Fmt(p2), Fmt(p3), Fmt(p4),
             Sanitize(note));

   if((g_TraceSeq % 100) == 0) FileFlush(g_TraceHandle);
  }

string StateSignature()
  {
   return EnumToString(g_S1.stage)  + "/" + IntegerToString(g_S1.dir)  + "/" + IntegerToString(g_S1.pbCount) +
          "/" + DoubleToString(g_S1.lvl1Qe, _Digits) + "/" + DoubleToString(g_S1.lvl2Qe, _Digits) +
          " || " + EnumToString(g_S2C.stage) + "/" + IntegerToString(g_S2C.dir) + "/" + IntegerToString(g_S2C.pbCount) +
          " || " + EnumToString(g_S2NStage) + "/" + IntegerToString(g_S2NDir) + "/" + g_S2NSLType +
          " || S3=" + (g_SessionBlockedS3 ? "1" : "0") +
          " FOMC=" + (g_FOMCBlockedNY ? "1" : "0") +
          " DD=" + (g_DailyDDBreached ? "1" : "0") +
          " || ord=" + IntegerToString(OrdersTotal()) + " pos=" + IntegerToString(PositionsTotal());
  }

//+------------------------------------------------------------------+
//| 4. CÁLCULO AUTOMÁTICO DE DST (NY Y BRÓKER)                       |
//+------------------------------------------------------------------+
int DayOfWeekDate(int year, int mon, int day)
  {
   MqlDateTime d;
   ZeroMemory(d);
   d.year = year;
   d.mon  = mon;
   d.day  = day;
   datetime t = StructToTime(d);
   TimeToStruct(t, d);
   return d.day_of_week;
  }

datetime MakeDateTimeUTC(int year, int mon, int day, int hour, int min)
  {
   MqlDateTime d;
   ZeroMemory(d);
   d.year = year;
   d.mon  = mon;
   d.day  = day;
   d.hour = hour;
   d.min  = min;
   return StructToTime(d);
  }

int CalcularOffsetNYSegundos(datetime srvTime)
  {
   if(!InpAutoDST)
      return InpServerOffsetFromNY * 3600;

   MqlDateTime dSrv;
   TimeToStruct(srvTime, dSrv);
   int yr = dSrv.year;

   int brokerOffsetUTC = InpBrokerWinterOffsetUTC;
   if(InpBrokerUsesEUDST)
     {
      int lastSunMar = 31 - DayOfWeekDate(yr, 3, 31);
      int lastSunOct = 31 - DayOfWeekDate(yr, 10, 31);
      datetime euStartSrv = MakeDateTimeUTC(yr, 3, lastSunMar, 1, 0) + InpBrokerWinterOffsetUTC * 3600;
      datetime euEndSrv   = MakeDateTimeUTC(yr, 10, lastSunOct, 1, 0) + (InpBrokerWinterOffsetUTC + 1) * 3600;
      if(srvTime >= euStartSrv && srvTime < euEndSrv)
         brokerOffsetUTC += 1;
     }

   datetime utcTime = srvTime - brokerOffsetUTC * 3600;
   MqlDateTime dUtc;
   TimeToStruct(utcTime, dUtc);
   int uYr = dUtc.year;

   int firstSunMar  = 1 + ((7 - DayOfWeekDate(uYr, 3, 1)) % 7);
   int secondSunMar = firstSunMar + 7;
   int firstSunNov  = 1 + ((7 - DayOfWeekDate(uYr, 11, 1)) % 7);

   datetime usStartUTC = MakeDateTimeUTC(uYr, 3, secondSunMar, 7, 0); // 02:00 EST = 07:00 UTC
   datetime usEndUTC   = MakeDateTimeUTC(uYr, 11, firstSunNov, 6, 0); // 02:00 EDT = 06:00 UTC

   int nyOffsetUTC = (utcTime >= usStartUTC && utcTime < usEndUTC) ? -4 : -5;
   return (brokerOffsetUTC - nyOffsetUTC) * 3600;
  }

//+------------------------------------------------------------------+
//| 5. PERSISTENCIA EN GLOBALVARIABLES Y SINCRONIZACIÓN HISTORIAL    |
//+------------------------------------------------------------------+
string GVKey(int dayKey, ulong magic, string suffix)
  {
   return "NOVA3_" + _Symbol + "_" + IntegerToString(dayKey) + "_" + IntegerToString((long)magic) + "_" + suffix;
  }

void LimpiarGlobalVariablesAntiguas(int activeDayKey)
  {
   if(MQLInfoInteger(MQL_TESTER)) return;
   string keepPrefix = "NOVA3_" + _Symbol + "_" + IntegerToString(activeDayKey) + "_";
   string symPrefix  = "NOVA3_" + _Symbol + "_";
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
     {
      string name = GlobalVariableName(i);
      if(StringFind(name, symPrefix) == 0 && StringFind(name, keepPrefix) != 0)
         GlobalVariableDel(name);
     }
  }

void GuardarMetadataGV(int dayKey, ulong magic, double initRisk, double maxRR, string slType, int tradesToday, bool inAsia)
  {
   if(MQLInfoInteger(MQL_TESTER)) return;
   GlobalVariableSet(GVKey(dayKey, magic, "RISK"), initRisk);
   GlobalVariableSet(GVKey(dayKey, magic, "MAXRR"), maxRR);
   GlobalVariableSet(GVKey(dayKey, magic, "TRADES"), (double)tradesToday);
   GlobalVariableSet(GVKey(dayKey, magic, "ASIA"), inAsia ? 1.0 : 0.0);
   int slCode = (slType == "SL A") ? 3 : ((slType == "SL M") ? 2 : ((slType == "SL C") ? 1 : 0));
   GlobalVariableSet(GVKey(dayKey, magic, "SLCODE"), (double)slCode);
  }

string DecodeSLType(int code)
  {
   if(code == 3) return "SL A";
   if(code == 2) return "SL M";
   if(code == 1) return "SL C";
   return "";
  }

double RecuperarInitRiskDesdeHistorial(ulong posTicket, ulong posIdentifier, double openPrice, double curSL, int dayKey, ulong magic, string &slTypeOut, double &maxRROut, bool &inAsiaOut)
  {
   if(!MQLInfoInteger(MQL_TESTER))
     {
      string rk = GVKey(dayKey, magic, "RISK");
      if(GlobalVariableCheck(rk))
        {
         double gvRisk = GlobalVariableGet(rk);
         if(gvRisk > 0.0)
           {
            if(GlobalVariableCheck(GVKey(dayKey, magic, "MAXRR")))
               maxRROut = GlobalVariableGet(GVKey(dayKey, magic, "MAXRR"));
            if(GlobalVariableCheck(GVKey(dayKey, magic, "SLCODE")))
               slTypeOut = DecodeSLType((int)GlobalVariableGet(GVKey(dayKey, magic, "SLCODE")));
            if(GlobalVariableCheck(GVKey(dayKey, magic, "ASIA")))
               inAsiaOut = (GlobalVariableGet(GVKey(dayKey, magic, "ASIA")) > 0.5);
            return gvRisk;
           }
        }
     }

   if(posIdentifier > 0 && HistoryOrderSelect(posIdentifier))
     {
      double origSL = HistoryOrderGetDouble(posIdentifier, ORDER_SL);
      if(origSL > 0.0)
        {
         double d = MathAbs(openPrice - origSL);
         if(d > 0.0) return d;
        }
     }

   if(HistorySelectByPosition((long)posIdentifier))
     {
      for(int i = 0; i < HistoryDealsTotal(); i++)
        {
         ulong dt = HistoryDealGetTicket(i);
         if(HistoryDealGetInteger(dt, DEAL_ENTRY) == DEAL_ENTRY_IN)
           {
            double dealSL = HistoryDealGetDouble(dt, DEAL_SL);
            if(dealSL > 0.0)
              {
               double d = MathAbs(openPrice - dealSL);
               if(d > 0.0) return d;
              }
           }
        }
     }

   if(curSL > 0.0)
     {
      double d = MathAbs(openPrice - curSL);
      if(d > 0.0) return d;
     }

   return 0.0;
  }

int ContarTradesHoyEnHistorial(datetime startSrv, ulong magic)
  {
   if(!HistorySelect(startSrv, TimeCurrent())) return 0;
   int count = 0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong dt = HistoryDealGetTicket(i);
      if(HistoryDealGetString(dt, DEAL_SYMBOL) == _Symbol &&
         (ulong)HistoryDealGetInteger(dt, DEAL_MAGIC) == magic &&
         HistoryDealGetInteger(dt, DEAL_ENTRY) == DEAL_ENTRY_IN)
         count++;
     }
   return count;
  }

bool TieneOrdenPendiente(ulong magic, ulong &outTicket, double &outPrice, double &outSL)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong t = OrderGetTicket(i);
      if(OrderSelect(t) && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == magic)
        {
         outTicket = t;
         outPrice  = OrderGetDouble(ORDER_PRICE_OPEN);
         outSL     = OrderGetDouble(ORDER_SL);
         return true;
        }
     }
   return false;
  }

bool TienePosicionAbiertaHoy(ulong magic, datetime srvDayStart, ulong &outTicket, ulong &outPosId, double &outOpen, double &outSL)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(PositionSelectByTicket(t) && PositionGetString(POSITION_SYMBOL) == _Symbol &&
         (ulong)PositionGetInteger(POSITION_MAGIC) == magic &&
         (datetime)PositionGetInteger(POSITION_TIME) >= srvDayStart)
        {
         outTicket = t;
         outPosId  = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
         outOpen   = PositionGetDouble(POSITION_PRICE_OPEN);
         outSL     = PositionGetDouble(POSITION_SL);
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| 6. CICLO DE VIDA DEL EXPERT ADVISOR                              |
//+------------------------------------------------------------------+
int      g_ATRHandle      = INVALID_HANDLE;
datetime g_LastATRBarTime = 0;
double   g_CachedATR      = 0.0;
double   g_CachedClose1   = 0.0;

int OnInit()
  {
   if(_Period != PERIOD_M5)
      Print("AVISO: La estrategia Nova está diseñada para temporalidad M5.");

   g_ATRHandle      = INVALID_HANDLE;
   g_LastATRBarTime = 0;
   g_CachedATR      = 0.0;
   g_CachedClose1   = 0.0;
   ArrayResize(g_CarryPos, 0);

   bool requiereATR = (InpTrailModeQe == TRAIL_ATR_SWING || InpTrailModeS2N == TRAIL_ATR_SWING ||
                       ((InpTrailModeQe == TRAIL_M5_SWING || InpTrailModeS2N == TRAIL_M5_SWING) && InpManualSwing_UseATRFallback));
   if(requiereATR)
     {
      g_ATRHandle = iATR(_Symbol, PERIOD_M5, MathMax(1, InpTrailX_ATRPeriod));
      if(g_ATRHandle == INVALID_HANDLE)
         Print("AVISO: no se pudo crear iATR; el respaldo ATR queda deshabilitado.");
     }

   g_NYOffsetSec = CalcularOffsetNYSegundos(TimeCurrent());

   trade.SetDeviationInPoints(30);
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   Comment("");
   g_HistorySynced = false;

   for(int i = 0; i < 10; i++) { g_HudCacheText[i] = ""; g_HudCacheColor[i] = clrNONE; }

   TraceInit();

   Print("NOVA v3.15 | ", _Symbol, " ", EnumToString(_Period),
         " | autoDST=", (InpAutoDST ? "ON" : "OFF"),
         " | offsetNY=", (g_NYOffsetSec / 3600), "h",
         " | trailQe=", EnumToString(InpTrailModeQe),
         " | trailS2N=", EnumToString(InpTrailModeS2N),
         " | graceMarketClose=", (InpGraceCloseMarket ? "ON" : "OFF(SL-0.25R)"),
         " | close1540=", (InpClose1540Rule ? "ON" : "OFF(AsiaMonitor)"),
         " | riesgo=", DoubleToString(InpRiskPercent, 2), "%");

   if(InpUseNewsFilter)
     {
      if(MQLInfoInteger(MQL_TESTER))
         CargarNoticiasHistoricasCSV();
      else
         ActualizarCalendarioNoticias(true);
     }

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   if(g_ATRHandle != INVALID_HANDLE)
     {
      IndicatorRelease(g_ATRHandle);
      g_ATRHandle = INVALID_HANDLE;
     }
   TraceClose();
   ObjectsDeleteAll(0, "NOVA_");
   Comment("");
  }

void OnTick()
  {
   datetime srvTime = TimeCurrent();

   if(InpAutoDST)
      g_NYOffsetSec = CalcularOffsetNYSegundos(srvTime);

   datetime nyTime = srvTime - g_NYOffsetSec;

   if(InpUseNewsFilter && !MQLInfoInteger(MQL_TESTER))
      ActualizarCalendarioNoticias(false);

   MqlDateTime dtNy;
   TimeToStruct(nyTime, dtNy);

   // Reinicio diario al cambiar de fecha en Nueva York (preservando posiciones arrastradas sin bloquear el nuevo día)
   int dayKey = dtNy.year * 10000 + dtNy.mon * 100 + dtNy.day;
   if(dayKey != g_ActiveDayKey)
     {
      if(g_ActiveDayKey > 0)
         CapturarPosicionesAlCambioDeDia();
      g_ActiveDayKey  = dayKey;
      g_HistorySynced = false;
      LimpiarGlobalVariablesAntiguas(dayKey);
      ResetearEstadoDiario();
     }

   // Marcas horarias del día actual
   datetime nyRangeStart, nyRangeEnd, nySessStart, nyLastEntry, nySessEnd;
   datetime nyAsiaStart, nyAsiaLastEntry, nyAsiaEnd;
   datetime srvDayStart, srvRangeStart, srvRangeEnd, srvSessStart, srvMarketOpen, srvSessEnd, srvAsiaLastEntry, srvAsiaEnd;
   ConstruirHorariosDia(dtNy, nyRangeStart, nyRangeEnd, nySessStart, nyLastEntry, nySessEnd,
                        nyAsiaStart, nyAsiaLastEntry, nyAsiaEnd,
                        srvDayStart, srvRangeStart, srvRangeEnd, srvSessStart, srvMarketOpen, srvSessEnd, srvAsiaLastEntry, srvAsiaEnd);

   // Guardia de pérdida diaria máxima (Prop Firm)
   ActualizarGuardiaDrawdownDiario(nyTime);

   // Evaluación de ventanas de noticias Bullfy y FOMC
   datetime fomcTime = 0;
   string   fomcTitle = "";
   bool bloqueadoPorNoticia = EstaBloqueadoPorNoticias(nyTime);
   bool cercaDeNoticia      = EstaEnVentanaRestringidaBullfy(nyTime, 120); // 2 min antes para pausar pendientes limpiamente
   g_FOMCBlockedNY          = (InpUseFOMCRule && HayFOMCProximo(nyTime, fomcTime, fomcTitle));

   // Gestión continua 24/7 de posiciones arrastradas de sesiones previas (actúa incluso entre 00:00 y 07:00 NY)
   GestionarPosicionesArrastradas(nyTime, srvTime, srvDayStart);

   // Activación opcional de sesión Asia a las 18:00 NY
   if(InpEnableAsiaSession && !g_AsiaActivatedToday && nyTime >= nyAsiaStart && nyTime <= nyAsiaLastEntry)
     {
      g_AsiaActivatedToday = true;
      ReactivarParaSesionAsia();
     }

   // Evaluación de fase de sesión y cálculo del rango (solo una vez tras 07:00 NY)
   string estado = "";
   color  clrEstado = clrSilver;

   if(nyTime < nyRangeStart)
     {
      estado = "ESPERANDO RANGO (02:00 NY)";
      g_RangeReady = false;
     }
   else if(nyTime >= nyRangeStart && nyTime < nyRangeEnd)
     {
      estado = "FORMANDO RANGO (02:00 - 07:00 NY)";
      clrEstado = clrMediumPurple;
      CalcularRango(srvRangeStart, srvTime, false);
      g_RangeReady = false;
     }
   else
     {
      if(!g_RangeFinalized)
        {
         g_RangeFinalized = CalcularRango(srvRangeStart, srvRangeEnd - 1, true);
         if(g_RangeFinalized)
           {
            g_LastValidRangeHigh = g_RangeHigh;
            g_LastValidRangeLow  = g_RangeLow;
           }
         else if(dtNy.day_of_week == 0 && InpEnableAsiaSession && InpAllowSundayAsia)
           {
            // Domingo sin sesión 02:00-07:00 propia: usar el rango del viernes previo ("nuestro rango sigue siendo el mismo")
            if(g_LastValidRangeHigh > g_LastValidRangeLow && g_LastValidRangeLow > 0.0)
              {
               g_RangeHigh      = g_LastValidRangeHigh;
               g_RangeLow       = g_LastValidRangeLow;
               g_RangeMid       = (g_RangeHigh + g_RangeLow) / 2.0;
               g_RangePct       = ((g_RangeHigh - g_RangeLow) / g_RangeLow) * 100.0;
               g_RangeFinalized = true;
              }
            else if(CalcularRango(srvRangeStart - 2 * 86400, srvRangeEnd - 2 * 86400 - 1, true))
              {
               g_LastValidRangeHigh = g_RangeHigh;
               g_LastValidRangeLow  = g_RangeLow;
               g_RangeFinalized     = true;
              }
           }
        }

      g_RangeReady = (g_RangeFinalized && g_RangeHigh > 0.0 && g_RangeLow > 0.0 && g_RangeHigh > g_RangeLow);

      if(g_RangeReady && !g_HistorySynced)
        {
         g_HistorySynced = true;
         if(!MQLInfoInteger(MQL_TESTER))
            ReconstruirEstructuraHoy(srvDayStart, srvRangeStart, srvRangeEnd, nySessStart, nyLastEntry, nyAsiaStart, nyAsiaLastEntry);
        }

      if(g_DailyDDBreached)
        {
         estado = "BLOQUEADO - LÍMITE DD DIARIO";
         clrEstado = clrCrimson;
         PausarPendientesPorBloqueo();
        }
      else if(g_SessionBlockedS3)
        {
         estado = "BLOQUEADO POR SETUP 3";
         clrEstado = clrTomato;
        }
      else if(g_FOMCBlockedNY)
        {
         int minsFOMC = (int)((fomcTime - nyTime) / 60);
         estado = (minsFOMC >= 0) ? ("FOMC EN " + IntegerToString(minsFOMC) + "M - FUERA") : "PAUSADO - FOMC";
         clrEstado = clrOrangeRed;
         PausarPendientesPorBloqueo();
         CerrarPosicionesPorFOMC(srvTime, nyTime);
        }
      else if(bloqueadoPorNoticia || (cercaDeNoticia && !InpKeepPreExistingPendingInNews))
        {
         estado = bloqueadoPorNoticia ? "PAUSADO - NOTICIA ROJA" : "PRE-NOTICIA ROJA (BULLFY)";
         clrEstado = clrGold;
         if(!InpKeepPreExistingPendingInNews)
            PausarPendientesPorBloqueo();
        }
      else if(nyTime < nySessStart)
        {
         estado = InpObserveFrom7AM ? "OBSERVANDO ESTRUCTURA (07-08 NY)" : "RANGO LISTO - ESPERANDO 08:00 NY";
         clrEstado = clrDodgerBlue;
        }
      else if(EstaEnVentanaEntradas(nyTime, nySessStart, nyLastEntry, nyAsiaStart, nyAsiaLastEntry))
        {
         estado = (nyTime >= nyAsiaStart) ? "VENTANA ASIA ACTIVA" : "VENTANA ENTRADAS NY ACTIVA";
         clrEstado = clrLimeGreen;
        }
      else if((nyTime > nyLastEntry && nyTime <= nySessEnd) ||
              (InpEnableAsiaSession && nyTime > nyAsiaLastEntry && nyTime <= nyAsiaEnd))
        {
         estado = "SOLO GESTIÓN (SIN NUEVAS)";
         clrEstado = clrGold;
        }
      else
        {
         estado = (PositionsTotal() > 0) ? "MONITOREO SL ASIA / NOCTURNO" : "FUERA DE HORARIO OPERATIVO";
         clrEstado = (PositionsTotal() > 0) ? clrDeepSkyBlue : clrGray;
        }
     }

   // Ejecución operativa cuando el rango diario es válido
   if(g_RangeReady)
     {
      if(!g_RangeLogged)
        {
         g_RangeLogged = true;
         TraceEv("DAY", "RANGE", 0, g_RangeHigh, g_RangeLow, g_RangeMid, g_RangePct,
                 "offset=" + IntegerToString(g_NYOffsetSec / 3600) + "h" +
                 " S1_1QR=" + Fmt(g_RangeHigh * (1.0 + InpS1_1QR_Pct / 100.0)) + "/" +
                 Fmt(g_RangeLow  * (1.0 - InpS1_1QR_Pct / 100.0)) +
                 " S2N_1QR=" + Fmt(g_RangeLow * (1.0 - InpS2N_1QR_Pct / 100.0)) + "/" +
                 Fmt(g_RangeHigh * (1.0 + InpS2N_1QR_Pct / 100.0)));
        }

      bool esperando930 = EnEsperaApertura930(nyTime);
      bool puedeColocar = EstaEnVentanaEntradas(nyTime, nySessStart, nyLastEntry + 59, nyAsiaStart, nyAsiaLastEntry + 59) &&
                          !esperando930 && !bloqueadoPorNoticia && !cercaDeNoticia && !g_FOMCBlockedNY && !g_SessionBlockedS3 && !g_DailyDDBreached;

      // Si había señales esperando apertura 08:00, cierre de vela 09:30 o fin de pausa por noticia, armarlas al entrar en ventana
      if(puedeColocar)
         IntentarArmarPendientesEnEspera(srvTime, nyTime, srvMarketOpen, nyLastEntry, nyAsiaStart, nyAsiaLastEntry, srvSessEnd, srvAsiaLastEntry);

      // Si se salió de la ventana de noticia, limpiar bandera de pausa tras evaluar rearmado
      if(!bloqueadoPorNoticia && !cercaDeNoticia && !g_FOMCBlockedNY && !g_DailyDDBreached)
        {
         g_S1.pausedByNews  = false;
         g_S2C.pausedByNews = false;
         g_S2NPausedByNews  = false;
        }

      // Gestión activa de pendientes y posiciones abiertas en la jornada actual
      GestionarMotorQe(g_S1,  MAGIC_S1,      "S1",  nyTime, srvTime, srvDayStart, false, nyLastEntry, nyAsiaStart, nyAsiaLastEntry);
      GestionarMotorQe(g_S2C, MAGIC_S2_CONT, "S2C", nyTime, srvTime, srvDayStart, true,  nyLastEntry, nyAsiaStart, nyAsiaLastEntry);
      GestionarSetup2Nacimiento(nyTime, srvTime, srvDayStart, nyLastEntry, nyAsiaStart, nyAsiaLastEntry);

      // Evaluación estructural por cierre de vela M5
      datetime barTime = iTime(_Symbol, PERIOD_M5, 0);
      if(barTime != g_LastBarTime)
        {
         g_LastBarTime = barTime;
         datetime closedBarSrv = iTime(_Symbol, PERIOD_M5, 1);
         datetime closedBarNY  = closedBarSrv - g_NYOffsetSec;

         bool enObservacion = (InpObserveFrom7AM && closedBarNY >= nyRangeEnd && !EstaFueraDeObservacion(closedBarNY, nyLastEntry, nyAsiaStart, nyAsiaLastEntry)) ||
                              EstaEnVentanaEntradas(closedBarNY, nySessStart, nyLastEntry, nyAsiaStart, nyAsiaLastEntry);

         if(enObservacion && !g_SessionBlockedS3 && !g_DailyDDBreached && !g_FOMCBlockedNY)
            EvaluarVela(closedBarNY, 1, false, puedeColocar, esperando930, nyLastEntry, nyAsiaStart, nyAsiaLastEntry, srvSessEnd, srvAsiaLastEntry);

         if(InpDebugTrace && InpTraceBars)
           {
            string sig = StateSignature();
            if(sig != g_LastStateSig)
              {
               g_LastStateSig = sig;
               TraceEv("BAR", "M5", 0,
                       iOpen(_Symbol, PERIOD_M5, 1), iHigh(_Symbol, PERIOD_M5, 1),
                       iLow(_Symbol, PERIOD_M5, 1),  iClose(_Symbol, PERIOD_M5, 1),
                       "bar=" + TimeToString(closedBarSrv, TIME_DATE|TIME_MINUTES) +
                       " obs=" + (enObservacion ? "1" : "0") +
                       " ord=" + (puedeColocar ? "1" : "0") +
                       " ny=" + TimeToString(closedBarNY, TIME_MINUTES) + " || " + sig);
              }
           }
        }
     }

   // Dibujo optimizado de escenario y HUD
   if(g_RangeHigh > 0.0 && g_RangeLow > 0.0)
     {
      datetime curBar = iTime(_Symbol, PERIOD_M5, 0);
      if(!g_RangeReady || curBar != g_LastScenarioBarDrawn)
        {
         g_LastScenarioBarDrawn = curBar;
         string dayTag = IntegerToString(dtNy.year) + "_" + IntegerToString(dtNy.mon) + "_" + IntegerToString(dtNy.day);
         DibujarEscenario(dayTag, srvRangeStart, srvRangeEnd, srvSessStart, srvMarketOpen, srvSessEnd);
        }
     }

   if(!MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE))
      ActualizarHUD(nyTime, estado, clrEstado);
  }

//+------------------------------------------------------------------+
//| 7. HORARIOS, REINICIO Y RECONSTRUCCIÓN DE ESTADO                 |
//+------------------------------------------------------------------+
void ConstruirHorariosDia(const MqlDateTime &dtNy,
                          datetime &nyRangeStart, datetime &nyRangeEnd, datetime &nySessStart, datetime &nyLastEntry, datetime &nySessEnd,
                          datetime &nyAsiaStart, datetime &nyAsiaLastEntry, datetime &nyAsiaEnd,
                          datetime &srvDayStart, datetime &srvRangeStart, datetime &srvRangeEnd, datetime &srvSessStart, datetime &srvMarketOpen,
                          datetime &srvSessEnd, datetime &srvAsiaLastEntry, datetime &srvAsiaEnd)
  {
   MqlDateTime dtTemp = dtNy;
   dtTemp.sec  = 0;
   dtTemp.hour = 0;                   dtTemp.min = 0;                  datetime nyDay0 = StructToTime(dtTemp);

   dtTemp.hour = InpRangeStartHour;   dtTemp.min = InpRangeStartMin;   nyRangeStart    = StructToTime(dtTemp);
   dtTemp.hour = InpRangeEndHour;     dtTemp.min = InpRangeEndMin;     nyRangeEnd      = StructToTime(dtTemp);
   dtTemp.hour = InpSessionStartHour; dtTemp.min = InpSessionStartMin; nySessStart     = StructToTime(dtTemp);
   dtTemp.hour = InpLastEntryHourNY;  dtTemp.min = InpLastEntryMinNY;  nyLastEntry     = StructToTime(dtTemp);
   dtTemp.hour = 9;                   dtTemp.min = 30;                 datetime nyOpen = StructToTime(dtTemp);
   dtTemp.hour = InpSessionEndHour;   dtTemp.min = InpSessionEndMin;   nySessEnd       = StructToTime(dtTemp);

   dtTemp.hour = InpAsiaStartHour;     dtTemp.min = InpAsiaStartMin;     nyAsiaStart     = StructToTime(dtTemp);
   dtTemp.hour = InpAsiaLastEntryHour; dtTemp.min = InpAsiaLastEntryMin; nyAsiaLastEntry = StructToTime(dtTemp);
   dtTemp.hour = InpAsiaEndHour;       dtTemp.min = InpAsiaEndMin;       nyAsiaEnd       = StructToTime(dtTemp);

   srvDayStart      = nyDay0          + g_NYOffsetSec;
   srvRangeStart    = nyRangeStart    + g_NYOffsetSec;
   srvRangeEnd      = nyRangeEnd      + g_NYOffsetSec;
   srvSessStart     = nySessStart     + g_NYOffsetSec;
   srvMarketOpen    = nyOpen          + g_NYOffsetSec;
   srvSessEnd       = nySessEnd       + g_NYOffsetSec;
   srvAsiaLastEntry = nyAsiaLastEntry + g_NYOffsetSec;
   srvAsiaEnd       = nyAsiaEnd       + g_NYOffsetSec;
  }

bool EstaEnVentanaEntradas(datetime nyTime, datetime nySessStart, datetime nyLastEntry, datetime nyAsiaStart, datetime nyAsiaLastEntry)
  {
   if(nyTime >= nySessStart && nyTime <= nyLastEntry) return true;
   if(InpEnableAsiaSession && nyTime >= nyAsiaStart && nyTime <= nyAsiaLastEntry) return true;
   return false;
  }

bool EnEsperaApertura930(datetime nyTime)
  {
   if(!InpFilter930Open) return false;
   MqlDateTime dt;
   TimeToStruct(nyTime, dt);
   int secOfDay = dt.hour * 3600 + dt.min * 60 + dt.sec;
   // Si el PE cae justo en 09:25 - 09:34:59 NY, esperar a las 09:35 NY (cierre de la vela de apertura 09:30)
   return (secOfDay >= (9 * 3600 + 25 * 60) && secOfDay < (9 * 3600 + 35 * 60));
  }

bool EstaFueraDeObservacion(datetime barNY, datetime nyLastEntry, datetime nyAsiaStart, datetime nyAsiaLastEntry)
  {
   if(barNY <= nyLastEntry) return false;
   if(InpEnableAsiaSession && barNY >= nyAsiaStart && barNY <= nyAsiaLastEntry) return false;
   return true;
  }

void ResetearQeMachine(QeMachine &m)
  {
   m.stage        = QE_INACTIVE;
   m.dir          = 0;
   m.extreme      = 0.0;
   m.lvl1Qe       = 0.0;
   m.lvl2Qe       = 0.0;
   m.pendingEntry = 0.0;
   m.pbCount      = 0;
   m.tradesToday  = 0;
   m.initRisk     = 0.0;
   m.maxRRReached = 0.0;
   m.slType       = "";
   m.open930Done  = false;
   m.graceDone    = false;
   m.pausedByNews = false;
   m.waitOpen930  = false;
   m.orderInAsia  = false;
  }

void ResetearEstadoDiario()
  {
   g_RangeHigh            = 0.0;
   g_RangeLow             = 0.0;
   g_RangeMid             = 0.0;
   g_RangePct             = 0.0;
   g_RangeReady           = false;
   g_RangeFinalized       = false;
   g_RangeLogged          = false;
   g_LastScenarioBarDrawn = 0;

   g_SessionBlockedS3     = false;
   g_FOMCBlockedNY        = false;
   g_DailyDDBreached      = false;
   g_AsiaActivatedToday   = false;
   g_DayStartBalance      = AccountInfoDouble(ACCOUNT_BALANCE);
   g_DayStartEquity       = AccountInfoDouble(ACCOUNT_EQUITY);
   if(!MQLInfoInteger(MQL_TESTER) && g_ActiveDayKey > 0)
     {
      string dbKey = GVKey(g_ActiveDayKey, 0, "DAYBAL");
      string deKey = GVKey(g_ActiveDayKey, 0, "DAYEQ");
      if(GlobalVariableCheck(dbKey) && GlobalVariableGet(dbKey) > 0.0)
         g_DayStartBalance = GlobalVariableGet(dbKey);
      else
         GlobalVariableSet(dbKey, g_DayStartBalance);
      if(GlobalVariableCheck(deKey) && GlobalVariableGet(deKey) > 0.0)
         g_DayStartEquity = GlobalVariableGet(deKey);
      else
         GlobalVariableSet(deKey, g_DayStartEquity);
     }

   g_Setup3Triggered      = false;
   g_HitHigh              = false;
   g_HitLow               = false;
   g_S3SecondSide         = 0;
   g_HadSideBreakout      = false;
   g_FirstBreakDir        = 0;
   g_S2NStructureConfirmed= false;
   g_S2NStructDir         = 0;

   ResetearQeMachine(g_S1);
   ResetearQeMachine(g_S2C);

   g_S2NStage             = S2N_WAIT_1QR;
   g_S2NDir               = 0;
   g_S2NExtreme           = 0.0;
   g_S2NProtectedExtreme  = 0.0;
   g_S2NXPivot            = 0.0;
   g_S2NCHLevel           = 0.0;
   g_S2NXPivotSet         = false;
   g_S2NCHLockedFromX     = false;
   g_S2NPullbackSeen      = false;
   g_S2NReached50         = false;
   g_S2NBOSHigh           = 0.0;
   g_S2NBOSLevel          = 0.0;
   g_S2NInternalRef       = 0.0;
   g_S2NInitRisk          = 0.0;
   g_S2NMaxRRReached      = 0.0;
   g_S2NSLType            = "";
   g_S2NOpen930Done       = false;
   g_S2NGraceDone         = false;
   g_S2NPausedByNews      = false;
   g_S2NWaitOpen930       = false;
   g_S2NOrderInAsia       = false;
   g_S2NTradesToday       = 0;
  }

void ReactivarParaSesionAsia()
  {
   if(g_SessionBlockedS3 || g_DailyDDBreached) return;

   if(InpEnableSetup1 && g_S1.stage == QE_FINISHED && (InpAsiaAllowIfNYTraded || g_S1.tradesToday == 0))
     {
      g_S1.stage = (g_S1.dir != 0) ? QE_WAIT_2QE_PB : QE_INACTIVE;
      g_S1.extreme = (g_S1.dir == 1) ? iHigh(_Symbol, PERIOD_M5, 1) : iLow(_Symbol, PERIOD_M5, 1);
      g_S1.pbCount = 0;
      g_S1.pausedByNews = false;
     }
   if(InpEnableSetup2Cont && g_S2C.stage == QE_FINISHED && (InpAsiaAllowIfNYTraded || g_S2C.tradesToday == 0))
     {
      g_S2C.stage = (g_S2C.dir != 0) ? QE_WAIT_2QE_PB : QE_INACTIVE;
      g_S2C.extreme = (g_S2C.dir == 1) ? iHigh(_Symbol, PERIOD_M5, 1) : iLow(_Symbol, PERIOD_M5, 1);
      g_S2C.pbCount = 0;
      g_S2C.pausedByNews = false;
     }
   if(InpEnableSetup2Nac && g_S2NStage == S2N_FINISHED && (InpAsiaAllowIfNYTraded || g_S2NTradesToday == 0))
     {
      g_S2NStage = S2N_WAIT_1QR;
      g_S2NPausedByNews = false;
     }
  }

void ReconstruirEstructuraHoy(datetime srvDayStart, datetime srvRangeStart, datetime srvRangeEnd, datetime nySessStart, datetime nyLastEntry, datetime nyAsiaStart, datetime nyAsiaLastEntry)
  {
   // 1. Contar trades reales ejecutados hoy desde 00:00 NY (evita duplicados sin contar arrastradas del día anterior)
   g_S1.tradesToday  = ContarTradesHoyEnHistorial(srvDayStart, MAGIC_S1);
   g_S2C.tradesToday = ContarTradesHoyEnHistorial(srvDayStart, MAGIC_S2_CONT);
   g_S2NTradesToday  = ContarTradesHoyEnHistorial(srvDayStart, MAGIC_S2_NAC);

   // 2. Reconstruir estructura de velas desde las 07:00 NY (o 08:00 si ObserveFrom7AM = false)
   datetime obsStartSrv = InpObserveFrom7AM ? srvRangeEnd : (nySessStart + g_NYOffsetSec);
   int startShift = iBarShift(_Symbol, PERIOD_M5, obsStartSrv, false);
   if(startShift >= 1)
     {
      for(int s = startShift; s >= 1; s--)
        {
         datetime barSrv = iTime(_Symbol, PERIOD_M5, s);
         datetime barNY  = barSrv - g_NYOffsetSec;
         if(!EstaFueraDeObservacion(barNY, nyLastEntry, nyAsiaStart, nyAsiaLastEntry) && !g_SessionBlockedS3)
            EvaluarVela(barNY, s, true, false, false, nyLastEntry, nyAsiaStart, nyAsiaLastEntry, 0, 0);
        }
     }

   // 3. Sincronizar estado real contra posiciones y órdenes abiertas HOY en el bróker
   SincronizarMaquinaConBrokerQe(g_S1,  MAGIC_S1,      srvDayStart, 1);
   SincronizarMaquinaConBrokerQe(g_S2C, MAGIC_S2_CONT, srvDayStart, 1);

   ulong posT = 0, posId = 0, ordT = 0;
   double openP = 0.0, curSL = 0.0, ordP = 0.0, ordSL = 0.0;
   if(TienePosicionAbiertaHoy(MAGIC_S2_NAC, srvDayStart, posT, posId, openP, curSL))
     {
      g_S2NStage = S2N_IN_TRADE;
      if(PositionSelectByTicket(posT))
         g_S2NDir = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
      g_S2NInitRisk = RecuperarInitRiskDesdeHistorial(posT, posId, openP, curSL, g_ActiveDayKey, MAGIC_S2_NAC,
                                                      g_S2NSLType, g_S2NMaxRRReached, g_S2NOrderInAsia);
     }
   else if(TieneOrdenPendiente(MAGIC_S2_NAC, ordT, ordP, ordSL))
     {
      g_S2NStage = S2N_ORDER_ACTIVE;
      g_S2NInitRisk = MathAbs(ordP - ordSL);
     }
   else if(g_S2NTradesToday >= InpS2N_MaxTradesPerDay)
     {
      g_S2NStage = S2N_FINISHED;
     }
   else if(g_S2NStage == S2N_ORDER_ACTIVE)
     {
      g_S2NStage = S2N_WAIT_CH;
     }
  }

void SincronizarMaquinaConBrokerQe(QeMachine &m, ulong magic, datetime srvDayStart, int maxTradesPerSetup)
  {
   ulong posT = 0, posId = 0, ordT = 0;
   double openP = 0.0, curSL = 0.0, ordP = 0.0, ordSL = 0.0;

   if(TienePosicionAbiertaHoy(magic, srvDayStart, posT, posId, openP, curSL))
     {
      m.stage = QE_IN_TRADE;
      if(PositionSelectByTicket(posT))
         m.dir = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
      m.initRisk = RecuperarInitRiskDesdeHistorial(posT, posId, openP, curSL, g_ActiveDayKey, magic,
                                                   m.slType, m.maxRRReached, m.orderInAsia);
     }
   else if(TieneOrdenPendiente(magic, ordT, ordP, ordSL))
     {
      m.stage = QE_ORDER_ACTIVE;
      m.initRisk = MathAbs(ordP - ordSL);
     }
   else if(m.tradesToday >= maxTradesPerSetup)
     {
      m.stage = QE_FINISHED;
     }
   else if(m.stage == QE_ORDER_ACTIVE || m.stage == QE_READY_ORDER)
     {
      m.stage = QE_WAIT_2QE_BRK;
     }
  }

//+------------------------------------------------------------------+
//| 8. MOTOR ESTRUCTURAL EN VELA M5 (S1, S2N, S2C Y SETUP 3)         |
//+------------------------------------------------------------------+
bool EvaluarFiltroSetup3(double open1, double high1, double low1, double close1, datetime time1, bool soloReconstruccion)
  {
   if(!InpEnableSetup3Filter) return false;
   if(g_SessionBlockedS3) return true;

   double outHigh = g_RangeHigh * (1.0 + InpS3_MinOutPct / 100.0);
   double outLow  = g_RangeLow  * (1.0 - InpS3_MinOutPct / 100.0);

   bool hitH = InpS3_RequireBodyBreak ? (close1 > outHigh) : (high1 > outHigh);
   bool hitL = InpS3_RequireBodyBreak ? (close1 < outLow)  : (low1  < outLow);

   // Desempatar orden intrabar con M1 si la misma vela toca ambos extremos
   if(hitH && hitL && !g_HitHigh && !g_HitLow)
     {
      bool hFirst = (close1 < open1);
      MqlRates m1[];
      ArraySetAsSeries(m1, false);
      if(CopyRates(_Symbol, PERIOD_M1, time1, time1 + 299, m1) > 0)
        {
         for(int k = 0; k < ArraySize(m1); k++)
           {
            if(m1[k].high > outHigh) { hFirst = true; break; }
            if(m1[k].low  < outLow)  { hFirst = false; break; }
           }
        }
      g_HitHigh      = true;
      g_HitLow       = true;
      g_S3SecondSide = hFirst ? -1 : 1;
     }
   else
     {
      if(hitH && !g_HitHigh)
        {
         g_HitHigh = true;
         if(g_HitLow && g_S3SecondSide == 0) g_S3SecondSide = 1;
        }
      if(hitL && !g_HitLow)
        {
         g_HitLow = true;
         if(g_HitHigh && g_S3SecondSide == 0) g_S3SecondSide = -1;
        }
     }

   if(g_HitHigh && g_HitLow && g_S3SecondSide != 0)
     {
      bool giroBajista = InpS3_RequireMidCross ?
                         (g_S3SecondSide == 1 && close1 <= g_RangeMid && close1 < open1) :
                         (g_S3SecondSide == 1 && close1 < g_RangeHigh && close1 < open1);
      bool giroAlcista = InpS3_RequireMidCross ?
                         (g_S3SecondSide == -1 && close1 >= g_RangeMid && close1 > open1) :
                         (g_S3SecondSide == -1 && close1 > g_RangeLow  && close1 > open1);

      if(giroBajista || giroAlcista)
        {
         g_Setup3Triggered  = true;
         g_SessionBlockedS3 = true;
         DibujarNivelEstructura("NOVA_S3_BLOCK_" + TimeToString(time1), time1, close1, "SETUP 3 STOP", clrTomato, giroBajista);
         TraceEv("BLOCK", "S3", -g_S3SecondSide, close1, g_RangeHigh, g_RangeLow, 0,
                 "Barrido bilateral + giro contrario confirmado");

         if(!soloReconstruccion)
            CancelarTodasLasPendientes();

         if(g_S1.stage != QE_IN_TRADE)  g_S1.stage = QE_FINISHED;
         if(g_S2C.stage != QE_IN_TRADE) g_S2C.stage = QE_FINISHED;
         if(g_S2NStage != S2N_IN_TRADE) g_S2NStage = S2N_FINISHED;
         return true;
        }
     }

   return false;
  }

void EvaluarVela(datetime nyTime, int shift, bool soloReconstruccion, bool puedeColocar, bool esperando930,
                 datetime nyLastEntry, datetime nyAsiaStart, datetime nyAsiaLastEntry,
                 datetime srvSessEnd, datetime srvAsiaLastEntry)
  {
   double open1   = iOpen(_Symbol, PERIOD_M5, shift);
   double high1   = iHigh(_Symbol, PERIOD_M5, shift);
   double low1    = iLow(_Symbol, PERIOD_M5, shift);
   double close1  = iClose(_Symbol, PERIOD_M5, shift);
   datetime time1 = iTime(_Symbol, PERIOD_M5, shift);

   if(EvaluarFiltroSetup3(open1, high1, low1, close1, time1, soloReconstruccion))
      return;

   MqlDateTime dt;
   TimeToStruct(nyTime, dt);
   int minsNY = dt.hour * 60 + dt.min;

   if(InpAvoid10AMHour && minsNY >= (10 * 60) && minsNY < (11 * 60))
      return;

   bool bloqueadoAperturaS2N = (InpS2N_AvoidOpen10AM && minsNY >= (9 * 60 + 25) && minsNY < (9 * 60 + 55));

   double s1Buy1QR   = g_RangeHigh * (1.0 + InpS1_1QR_Pct / 100.0);
   double s1Sell1QR  = g_RangeLow  * (1.0 - InpS1_1QR_Pct / 100.0);
   double s2nBuy1QR  = g_RangeLow  * (1.0 - InpS2N_1QR_Pct / 100.0);
   double s2nSell1QR = g_RangeHigh * (1.0 + InpS2N_1QR_Pct / 100.0);

   // Registro autónomo del primer barrido/quiebre (>= 0.05%) para Setup 2 Continuación
   if(!g_HadSideBreakout)
     {
      if(low1 <= s2nBuy1QR && high1 >= s2nSell1QR)
        {
         g_HadSideBreakout = true;
         g_FirstBreakDir   = (close1 >= open1) ? -1 : 1;
        }
      else if(low1 <= s2nBuy1QR)
        {
         g_HadSideBreakout = true;
         g_FirstBreakDir   = -1;
        }
      else if(high1 >= s2nSell1QR)
        {
         g_HadSideBreakout = true;
         g_FirstBreakDir   = 1;
        }
     }

   //--- A. Setup 2 Nacimiento: 1QR >= 0.05% (con o sin cuerpo). NO invalida Setup 1.
   bool s2nRecienActivado = false;
   if(InpEnableSetup2Nac && !bloqueadoAperturaS2N && g_S2NStage == S2N_WAIT_1QR && g_S2NTradesToday < InpS2N_MaxTradesPerDay)
     {
      if(low1 <= s2nBuy1QR)
        {
         g_S2NDir = 1; g_S2NExtreme = low1; g_S2NXPivot = high1; g_S2NCHLevel = high1;
         g_S2NXPivotSet = false; g_S2NCHLockedFromX = false; g_S2NPullbackSeen = false; g_S2NReached50 = false; g_S2NInternalRef = low1;
         g_S2NStage = S2N_WAIT_CH;
         s2nRecienActivado = true;
         DibujarNivelEstructura("NOVA_S2N_1QR_" + TimeToString(time1), time1, low1, "S2 Nac 1QR", clrDarkOrange, false);
        }
      else if(high1 >= s2nSell1QR)
        {
         g_S2NDir = -1; g_S2NExtreme = high1; g_S2NXPivot = low1; g_S2NCHLevel = low1;
         g_S2NXPivotSet = false; g_S2NCHLockedFromX = false; g_S2NPullbackSeen = false; g_S2NReached50 = false; g_S2NInternalRef = high1;
         g_S2NStage = S2N_WAIT_CH;
         s2nRecienActivado = true;
         DibujarNivelEstructura("NOVA_S2N_1QR_" + TimeToString(time1), time1, high1, "S2 Nac 1QR", clrDarkOrange, true);
        }
     }

   //--- B. Progresión Setup 2 Nacimiento (solo en velas posteriores al 1QR)
   if(InpEnableSetup2Nac && !s2nRecienActivado && g_S2NStage != S2N_WAIT_1QR && g_S2NStage != S2N_FINISHED)
      ProcesarSetup2NacimientoVela(open1, high1, low1, close1, time1, soloReconstruccion, puedeColocar, esperando930,
                                    nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);

   //--- C. Setup 2 Continuación: Quiebre opuesto >= 0.15% con cuerpo (se evalúa ANTES de S1: si activa, invalida S1)
   bool structOkS2C       = !InpS2C_RequireS2NStructure || (g_S2NStructureConfirmed && g_S2NStructDir == -g_FirstBreakDir);
   bool s2cRecienActivado = false;
   if(InpEnableSetup2Cont && g_HadSideBreakout && structOkS2C && g_S2C.stage == QE_INACTIVE && g_S2C.tradesToday == 0)
     {
      double s2cBuy2QR  = g_RangeHigh * (1.0 + InpS2C_2QR_Pct / 100.0);
      double s2cSell2QR = g_RangeLow  * (1.0 - InpS2C_2QR_Pct / 100.0);

      if(g_FirstBreakDir == -1 && close1 >= s2cBuy2QR && close1 > open1)
        {
         g_S2C.dir = 1; g_S2C.extreme = high1; g_S2C.pbCount = 0; g_S2C.stage = QE_WAIT_1QE_PB;
         DibujarNivelEstructura("NOVA_S2C_2QR_" + TimeToString(time1), time1, high1, "S2C 2QR", clrTeal, true);
         s2cRecienActivado = true;
        }
      else if(g_FirstBreakDir == 1 && close1 <= s2cSell2QR && close1 < open1)
        {
         g_S2C.dir = -1; g_S2C.extreme = low1; g_S2C.pbCount = 0; g_S2C.stage = QE_WAIT_1QE_PB;
         DibujarNivelEstructura("NOVA_S2C_2QR_" + TimeToString(time1), time1, low1, "S2C 2QR", clrMaroon, false);
         s2cRecienActivado = true;
        }

      if(s2cRecienActivado && InpS2C_InvalidatesS1)
        {
         if(!soloReconstruccion)
            CancelarPendientesPorMagic(MAGIC_S1);
         if(g_S1.stage != QE_IN_TRADE)
           {
            g_S1.stage        = QE_FINISHED;
            g_S1.pausedByNews = false;
            g_S1.waitOpen930  = false;
            TraceEv("INVALIDATE", "S1", g_S2C.dir, close1, 0, 0, 0, "S1 invalidado al activarse S2C");
           }
        }
     }

   //--- D. Setup 1: 1QR >= 0.20% con cuerpo (sigue operable aunque S2N se haya activado, mientras S2C no lo haya invalidado)
   bool s1RecienActivado = false;
   if(InpEnableSetup1 && g_S1.stage == QE_INACTIVE && g_S1.tradesToday == 0)
     {
      if(close1 >= s1Buy1QR && close1 > open1)
        {
         g_S1.dir = 1; g_S1.extreme = high1; g_S1.pbCount = 0; g_S1.stage = QE_WAIT_1QE_PB;
         s1RecienActivado = true;
         DibujarNivelEstructura("NOVA_S1_1QR_" + TimeToString(time1), time1, high1, "S1 1QR", clrDodgerBlue, true);
        }
      else if(close1 <= s1Sell1QR && close1 < open1)
        {
         g_S1.dir = -1; g_S1.extreme = low1; g_S1.pbCount = 0; g_S1.stage = QE_WAIT_1QE_PB;
         s1RecienActivado = true;
         DibujarNivelEstructura("NOVA_S1_1QR_" + TimeToString(time1), time1, low1, "S1 1QR", clrCrimson, false);
        }
     }

   //--- E. Progresión Motor Qe (estrictamente desde la vela SIGUIENTE al 1QR/2QR para no auto-contar 1QR como 1Qe)
   if(InpEnableSetup1 && !s1RecienActivado && g_S1.stage != QE_INACTIVE && g_S1.stage != QE_FINISHED)
      ProcesarMotorQeVela(g_S1, MAGIC_S1, false, open1, high1, low1, close1, time1,
                          soloReconstruccion, puedeColocar, esperando930, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);

   if(InpEnableSetup2Cont && !s2cRecienActivado && g_S2C.stage != QE_INACTIVE && g_S2C.stage != QE_FINISHED)
      ProcesarMotorQeVela(g_S2C, MAGIC_S2_CONT, true, open1, high1, low1, close1, time1,
                          soloReconstruccion, puedeColocar, esperando930, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
  }

void ProcesarSetup2NacimientoVela(double open1, double high1, double low1, double close1, datetime time1,
                                   bool soloReconstruccion, bool puedeColocar, bool esperando930,
                                   datetime nyTime, datetime nyAsiaStart, datetime srvSessEnd, datetime srvAsiaLastEntry)
  {
   if(g_S2NStage == S2N_ORDER_ACTIVE || g_S2NStage == S2N_IN_TRADE) return;

   double rangeSize = g_RangeHigh - g_RangeLow;
   double reactFrac = InpS2N_ReactionZonePct / 100.0;

   if(g_S2NDir == 1) // Compra: barrido bajo g_RangeLow
     {
      if(g_S2NStage == S2N_WAIT_CH)
        {
         if(low1 < g_S2NExtreme)
           {
            g_S2NExtreme = low1;
            if(g_S2NXPivotSet)
              {
               g_S2NCHLevel       = g_S2NXPivot; // Fija el pivote X previo como CH protegido
               g_S2NCHLockedFromX = true;
              }
            else if(!g_S2NCHLockedFromX)
               g_S2NCHLevel = high1;
            g_S2NXPivot       = high1;
            g_S2NXPivotSet    = false;
            g_S2NPullbackSeen = false;
            return;
           }
         if(high1 > g_S2NXPivot)
           {
            g_S2NXPivot    = high1;
            g_S2NXPivotSet = true;
           }
         if(close1 < open1)
           {
            g_S2NPullbackSeen = true;
            if(g_S2NXPivotSet)
               g_S2NCHLevel = MathMax(g_S2NCHLevel, g_S2NXPivot);
           }
         if(close1 > g_S2NCHLevel && close1 > open1 && close1 > g_RangeLow)
           {
            g_S2NProtectedExtreme   = g_S2NExtreme;
            g_S2NInternalRef        = low1;
            g_S2NStructureConfirmed = true;
            g_S2NStructDir          = 1;
            g_S2NBOSHigh            = high1;
            g_S2NReached50          = (high1 >= g_RangeLow + rangeSize * reactFrac);
            g_S2NPullbackSeen       = false;
            DibujarNivelEstructura("NOVA_S2N_CH_" + TimeToString(time1), time1, g_S2NCHLevel, "S2 CH", clrDarkOrange, true);

            if(!InpS2N_Strict50BOS)
              {
               g_S2NStage       = S2N_READY_ORDER;
               g_S2NWaitOpen930 = esperando930;
               if(puedeColocar && !soloReconstruccion)
                  ConfirmarYColocarS2Nac(time1, false, 0.0, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
               return;
              }
            g_S2NStage = S2N_WAIT_50_REACTION;
           }
        }
      else if(g_S2NStage == S2N_WAIT_50_REACTION)
        {
         if(low1 < g_S2NProtectedExtreme)
           {
            g_S2NExtreme = low1; g_S2NCHLockedFromX = false; g_S2NXPivot = high1; g_S2NCHLevel = high1;
            g_S2NXPivotSet = false; g_S2NStage = S2N_WAIT_CH; g_S2NPullbackSeen = false; return;
           }
         if(low1 < g_S2NInternalRef && close1 > g_S2NProtectedExtreme) g_S2NInternalRef = low1;
         if(high1 >= g_RangeLow + rangeSize * reactFrac) g_S2NReached50 = true;

         double prevBOSHigh = g_S2NBOSHigh;
         if(high1 > g_S2NBOSHigh) g_S2NBOSHigh = high1;

         if(g_S2NReached50 && (close1 < open1 || high1 <= prevBOSHigh))
           {
            g_S2NBOSLevel = g_S2NBOSHigh;
            g_S2NStage    = S2N_WAIT_BOS;
            DibujarNivelEstructura("NOVA_S2N_BOS_" + TimeToString(time1), time1, g_S2NBOSLevel, "S2 BOS lvl", clrOrange, true);
           }
        }
      else if(g_S2NStage == S2N_WAIT_BOS)
        {
         if(low1 < g_S2NProtectedExtreme)
           {
            g_S2NExtreme = low1; g_S2NCHLockedFromX = false; g_S2NXPivot = high1; g_S2NCHLevel = high1;
            g_S2NXPivotSet = false; g_S2NStage = S2N_WAIT_CH; g_S2NPullbackSeen = false; return;
           }
         if(low1 < g_S2NInternalRef) g_S2NInternalRef = low1;
         if(close1 > g_S2NBOSLevel && close1 > open1)
           {
            g_S2NStage       = S2N_READY_ORDER;
            g_S2NWaitOpen930 = esperando930;
            if(puedeColocar && !soloReconstruccion)
               ConfirmarYColocarS2Nac(time1, false, 0.0, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
           }
         else if(high1 > g_S2NBOSLevel)
            g_S2NBOSLevel = high1;
        }
     }
   else if(g_S2NDir == -1) // Venta: barrido sobre g_RangeHigh
     {
      if(g_S2NStage == S2N_WAIT_CH)
        {
         if(high1 > g_S2NExtreme)
           {
            g_S2NExtreme = high1;
            if(g_S2NXPivotSet)
              {
               g_S2NCHLevel       = g_S2NXPivot; // Fija el pivote X previo como CH protegido
               g_S2NCHLockedFromX = true;
              }
            else if(!g_S2NCHLockedFromX)
               g_S2NCHLevel = low1;
            g_S2NXPivot       = low1;
            g_S2NXPivotSet    = false;
            g_S2NPullbackSeen = false;
            return;
           }
         if(low1 < g_S2NXPivot)
           {
            g_S2NXPivot    = low1;
            g_S2NXPivotSet = true;
           }
         if(close1 > open1)
           {
            g_S2NPullbackSeen = true;
            if(g_S2NXPivotSet)
               g_S2NCHLevel = MathMin(g_S2NCHLevel, g_S2NXPivot);
           }
         if(close1 < g_S2NCHLevel && close1 < open1 && close1 < g_RangeHigh)
           {
            g_S2NProtectedExtreme   = g_S2NExtreme;
            g_S2NInternalRef        = high1;
            g_S2NStructureConfirmed = true;
            g_S2NStructDir          = -1;
            g_S2NBOSHigh            = low1;
            g_S2NReached50          = (low1 <= g_RangeHigh - rangeSize * reactFrac);
            g_S2NPullbackSeen       = false;
            DibujarNivelEstructura("NOVA_S2N_CH_" + TimeToString(time1), time1, g_S2NCHLevel, "S2 CH", clrDarkOrange, false);

            if(!InpS2N_Strict50BOS)
              {
               g_S2NStage       = S2N_READY_ORDER;
               g_S2NWaitOpen930 = esperando930;
               if(puedeColocar && !soloReconstruccion)
                  ConfirmarYColocarS2Nac(time1, false, 0.0, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
               return;
              }
            g_S2NStage = S2N_WAIT_50_REACTION;
           }
        }
      else if(g_S2NStage == S2N_WAIT_50_REACTION)
        {
         if(high1 > g_S2NProtectedExtreme)
           {
            g_S2NExtreme = high1; g_S2NCHLockedFromX = false; g_S2NXPivot = low1; g_S2NCHLevel = low1;
            g_S2NXPivotSet = false; g_S2NStage = S2N_WAIT_CH; g_S2NPullbackSeen = false; return;
           }
         if(high1 > g_S2NInternalRef && close1 < g_S2NProtectedExtreme) g_S2NInternalRef = high1;
         if(low1 <= g_RangeHigh - rangeSize * reactFrac) g_S2NReached50 = true;

         double prevBOSLow = g_S2NBOSHigh;
         if(low1 < g_S2NBOSHigh) g_S2NBOSHigh = low1;

         if(g_S2NReached50 && (close1 > open1 || low1 >= prevBOSLow))
           {
            g_S2NBOSLevel = g_S2NBOSHigh;
            g_S2NStage    = S2N_WAIT_BOS;
            DibujarNivelEstructura("NOVA_S2N_BOS_" + TimeToString(time1), time1, g_S2NBOSLevel, "S2 BOS lvl", clrOrange, false);
           }
        }
      else if(g_S2NStage == S2N_WAIT_BOS)
        {
         if(high1 > g_S2NProtectedExtreme)
           {
            g_S2NExtreme = high1; g_S2NCHLockedFromX = false; g_S2NXPivot = low1; g_S2NCHLevel = low1;
            g_S2NXPivotSet = false; g_S2NStage = S2N_WAIT_CH; g_S2NPullbackSeen = false; return;
           }
         if(high1 > g_S2NInternalRef) g_S2NInternalRef = high1;
         if(close1 < g_S2NBOSLevel && close1 < open1)
           {
            g_S2NStage       = S2N_READY_ORDER;
            g_S2NWaitOpen930 = esperando930;
            if(puedeColocar && !soloReconstruccion)
               ConfirmarYColocarS2Nac(time1, false, 0.0, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
           }
         else if(low1 < g_S2NBOSLevel)
            g_S2NBOSLevel = low1;
        }
     }
  }

void ConfirmarYColocarS2Nac(datetime time1, bool soloReconstruccion, double open930ExtremePrice,
                            datetime nyTime, datetime nyAsiaStart, datetime srvSessEnd, datetime srvAsiaLastEntry)
  {
   if(g_S2NTradesToday >= InpS2N_MaxTradesPerDay) { g_S2NStage = S2N_FINISHED; return; }

   double rangeSize = g_RangeHigh - g_RangeLow;
   double frac      = InpS2N_EntryLevelPct / 100.0;
   double minStop   = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double entBuf    = IndexPtsToPrice(InpEntryBufferPts);
   double slBuf     = IndexPtsToPrice(InpSLBufferPts);
   double entry75   = 0.0;
   double slPrice   = 0.0;
   double distPct   = 0.0;
   ENUM_ORDER_TYPE oType;

   double protExt = (g_S2NProtectedExtreme > 0.0) ? g_S2NProtectedExtreme : g_S2NExtreme;

   if(g_S2NDir == 1)
     {
      oType   = ORDER_TYPE_BUY_STOP;
      entry75 = NormalizeDouble(g_RangeLow + rangeSize * frac, _Digits);
      if(open930ExtremePrice > 0.0)
         entry75 = MathMax(entry75, NormalizeDouble(open930ExtremePrice + entBuf, _Digits));

      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(!soloReconstruccion && ask >= entry75 - minStop)
        {
         double altEntry = NormalizeDouble(MathMax(iHigh(_Symbol, PERIOD_M5, 1), ask) + entBuf, _Digits);
         if(altEntry <= g_RangeHigh + rangeSize * 0.10)
            entry75 = altEntry;
         else
           {
            TraceEv("SKIP", "S2N", g_S2NDir, entry75, ask, 0, 0, "precio ya supero el rango completo");
            g_S2NStage = S2N_FINISHED;
            return;
           }
        }

      distPct = ((g_RangeLow - protExt) / g_RangeLow) * 100.0;
      if(distPct > InpS2N_SL_AgresPct)
        {
         double sweep = MathMax(0.0, g_RangeLow - protExt);
         slPrice = MathMin(g_RangeLow - slBuf, g_RangeLow - sweep * InpS2N_SL_AgresSweepFrac);
         g_S2NSLType = "SL A";
        }
      else if(distPct >= InpS2N_SL_ModMinPct)
        {
         slPrice = (g_S2NInternalRef > protExt && g_S2NInternalRef < g_RangeLow) ?
                   (g_S2NInternalRef - slBuf) : ((g_RangeLow + protExt) / 2.0);
         g_S2NSLType = "SL M";
        }
      else
        {
         slPrice = protExt - slBuf;
         g_S2NSLType = "SL C";
        }
     }
   else
     {
      oType   = ORDER_TYPE_SELL_STOP;
      entry75 = NormalizeDouble(g_RangeHigh - rangeSize * frac, _Digits);
      if(open930ExtremePrice > 0.0)
         entry75 = MathMin(entry75, NormalizeDouble(open930ExtremePrice - entBuf, _Digits));

      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(!soloReconstruccion && bid <= entry75 + minStop)
        {
         double altEntry = NormalizeDouble(MathMin(iLow(_Symbol, PERIOD_M5, 1), bid) - entBuf, _Digits);
         if(altEntry >= g_RangeLow - rangeSize * 0.10)
            entry75 = altEntry;
         else
           {
            TraceEv("SKIP", "S2N", g_S2NDir, entry75, bid, 0, 0, "precio ya supero el rango completo");
            g_S2NStage = S2N_FINISHED;
            return;
           }
        }

      distPct = ((protExt - g_RangeHigh) / g_RangeHigh) * 100.0;
      if(distPct > InpS2N_SL_AgresPct)
        {
         double sweep = MathMax(0.0, protExt - g_RangeHigh);
         slPrice = MathMax(g_RangeHigh + slBuf, g_RangeHigh + sweep * InpS2N_SL_AgresSweepFrac);
         g_S2NSLType = "SL A";
        }
      else if(distPct >= InpS2N_SL_ModMinPct)
        {
         slPrice = (g_S2NInternalRef < protExt && g_S2NInternalRef > g_RangeHigh) ?
                   (g_S2NInternalRef + slBuf) : ((g_RangeHigh + protExt) / 2.0);
         g_S2NSLType = "SL M";
        }
      else
        {
         slPrice = protExt + slBuf;
         g_S2NSLType = "SL C";
        }
     }

   slPrice = NormalizeDouble(slPrice, _Digits);
   double distSL = MathAbs(entry75 - slPrice);
   if(distSL <= _Point) return;

   g_S2NInitRisk     = distSL;
   g_S2NMaxRRReached = 0.0;
   DibujarNivelEstructura("NOVA_S2N_PE_" + TimeToString(time1), time1, entry75, "S2 NAC 75%", clrDarkOrange, (g_S2NDir == 1));

   if(soloReconstruccion) { g_S2NStage = S2N_ORDER_ACTIVE; return; }

   double tpPrice = (oType == ORDER_TYPE_BUY_STOP) ?
                    NormalizeDouble(entry75 + distSL * InpTP_R_S2N, _Digits) :
                    NormalizeDouble(entry75 - distSL * InpTP_R_S2N, _Digits);

   bool inAsia = (InpEnableAsiaSession && nyTime >= nyAsiaStart);
   if(EnviarOrdenStop(MAGIC_S2_NAC, "S2N", g_S2NDir, oType, entry75, slPrice, tpPrice,
                      inAsia ? srvAsiaLastEntry : srvSessEnd,
                      (oType == ORDER_TYPE_BUY_STOP) ? "NOVA_S2_NAC_BUY" : "NOVA_S2_NAC_SELL"))
     {
      g_S2NStage        = S2N_ORDER_ACTIVE;
      g_S2NOrderInAsia  = inAsia;
      g_S2NPausedByNews = false;
      g_S2NWaitOpen930  = false;
      GuardarMetadataGV(g_ActiveDayKey, MAGIC_S2_NAC, g_S2NInitRisk, g_S2NMaxRRReached, g_S2NSLType, g_S2NTradesToday, inAsia);
     }
  }

bool EsVelaPullbackQe(int dir, double open1, double high1, double low1, double close1, double prevExtreme)
  {
   if(InpQePBMode == PB_MODE_LEGACY)
      return (dir == 1) ? (high1 <= prevExtreme) : (low1 >= prevExtreme);

   // Fiel a la regla: vela contraria (incluso si dejó mecha superior/inferior) O detenimiento sin superar el extremo previo
   bool esContraria    = (dir == 1) ? (close1 < open1) : (close1 > open1);
   bool esDetenimiento = (dir == 1) ? (high1 <= prevExtreme) : (low1 >= prevExtreme);
   return (esContraria || esDetenimiento);
  }

void ProcesarMotorQeVela(QeMachine &m, ulong magic, bool esContinuacion,
                         double open1, double high1, double low1, double close1, datetime time1,
                         bool soloReconstruccion, bool puedeColocar, bool esperando930,
                         datetime nyTime, datetime nyAsiaStart, datetime srvSessEnd, datetime srvAsiaLastEntry)
  {
   if(m.stage == QE_ORDER_ACTIVE || m.stage == QE_IN_TRADE || m.stage == QE_FINISHED) return;
   string prefix  = esContinuacion ? "S2C" : "S1";
   int reqPB      = MathMax(1, InpPullbackCandles);
   double entBuf  = IndexPtsToPrice(InpEntryBufferPts);
   bool allowDeep = esContinuacion ? InpS2C_AllowDeepPullback : InpS1_AllowDeepPullback;

   if(m.dir == 1)
     {
      if(!allowDeep && close1 < g_RangeLow) { m.stage = QE_FINISHED; return; }

      if(m.stage == QE_WAIT_1QE_PB)
        {
         double prevExt = m.extreme;
         if(high1 > m.extreme) m.extreme = high1;

         if(high1 > prevExt && close1 > open1)
            m.pbCount = 0;
         else if(EsVelaPullbackQe(1, open1, high1, low1, close1, prevExt))
           {
            if(++m.pbCount >= reqPB)
              {
               m.lvl1Qe = m.extreme; m.stage = QE_WAIT_1QE_BRK;
               DibujarNivelEstructura("NOVA_" + prefix + "_1QE_" + TimeToString(time1), time1, m.lvl1Qe, prefix + " 1Qe", clrDodgerBlue, true);
              }
           }
        }
      else if(m.stage == QE_WAIT_1QE_BRK)
        {
         if(close1 > m.lvl1Qe && close1 > open1)
           {
            m.extreme = high1; m.pbCount = 0; m.stage = QE_WAIT_2QE_PB;
           }
         else if(high1 > m.lvl1Qe)
            m.lvl1Qe = high1;
        }
      else if(m.stage == QE_WAIT_2QE_PB)
        {
         double prevExt = m.extreme;
         if(high1 > m.extreme) m.extreme = high1;

         if(high1 > prevExt && close1 > open1)
            m.pbCount = 0;
         else if(EsVelaPullbackQe(1, open1, high1, low1, close1, prevExt))
           {
            if(++m.pbCount >= reqPB)
              {
               m.lvl2Qe = m.extreme;
               DibujarNivelEstructura("NOVA_" + prefix + "_2QE_" + TimeToString(time1), time1, m.lvl2Qe, prefix + " 2Qe", clrForestGreen, true);
               if(InpDirect2QeEntry)
                 {
                  m.pendingEntry = NormalizeDouble(m.lvl2Qe + entBuf, _Digits);
                  m.stage        = QE_READY_ORDER;
                  m.waitOpen930  = esperando930;
                  if(puedeColocar && !soloReconstruccion)
                     ColocarOrdenMotorQe(m, magic, esContinuacion, ORDER_TYPE_BUY_STOP, m.pendingEntry, false, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
                 }
               else
                  m.stage = QE_WAIT_2QE_BRK;
              }
           }
        }
      else if(m.stage == QE_WAIT_2QE_BRK)
        {
         if(close1 > m.lvl2Qe && close1 > open1)
           {
            m.pendingEntry = NormalizeDouble(high1 + entBuf, _Digits);
            m.stage        = QE_READY_ORDER;
            m.waitOpen930  = esperando930;
            DibujarNivelEstructura("NOVA_" + prefix + "_PE_" + TimeToString(time1), time1, m.pendingEntry, prefix + " PE", clrForestGreen, true);
            if(puedeColocar && !soloReconstruccion)
               ColocarOrdenMotorQe(m, magic, esContinuacion, ORDER_TYPE_BUY_STOP, m.pendingEntry, false, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
           }
         else if(high1 > m.lvl2Qe)
            m.lvl2Qe = high1;
        }
     }
   else if(m.dir == -1)
     {
      if(!allowDeep && close1 > g_RangeHigh) { m.stage = QE_FINISHED; return; }

      if(m.stage == QE_WAIT_1QE_PB)
        {
         double prevExt = m.extreme;
         if(low1 < m.extreme) m.extreme = low1;

         if(low1 < prevExt && close1 < open1)
            m.pbCount = 0;
         else if(EsVelaPullbackQe(-1, open1, high1, low1, close1, prevExt))
           {
            if(++m.pbCount >= reqPB)
              {
               m.lvl1Qe = m.extreme; m.stage = QE_WAIT_1QE_BRK;
               DibujarNivelEstructura("NOVA_" + prefix + "_1QE_" + TimeToString(time1), time1, m.lvl1Qe, prefix + " 1Qe", clrCrimson, false);
              }
           }
        }
      else if(m.stage == QE_WAIT_1QE_BRK)
        {
         if(close1 < m.lvl1Qe && close1 < open1)
           {
            m.extreme = low1; m.pbCount = 0; m.stage = QE_WAIT_2QE_PB;
           }
         else if(low1 < m.lvl1Qe)
            m.lvl1Qe = low1;
        }
      else if(m.stage == QE_WAIT_2QE_PB)
        {
         double prevExt = m.extreme;
         if(low1 < m.extreme) m.extreme = low1;

         if(low1 < prevExt && close1 < open1)
            m.pbCount = 0;
         else if(EsVelaPullbackQe(-1, open1, high1, low1, close1, prevExt))
           {
            if(++m.pbCount >= reqPB)
              {
               m.lvl2Qe = m.extreme;
               DibujarNivelEstructura("NOVA_" + prefix + "_2QE_" + TimeToString(time1), time1, m.lvl2Qe, prefix + " 2Qe", clrFireBrick, false);
               if(InpDirect2QeEntry)
                 {
                  m.pendingEntry = NormalizeDouble(m.lvl2Qe - entBuf, _Digits);
                  m.stage        = QE_READY_ORDER;
                  m.waitOpen930  = esperando930;
                  if(puedeColocar && !soloReconstruccion)
                     ColocarOrdenMotorQe(m, magic, esContinuacion, ORDER_TYPE_SELL_STOP, m.pendingEntry, false, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
                 }
               else
                  m.stage = QE_WAIT_2QE_BRK;
              }
           }
        }
      else if(m.stage == QE_WAIT_2QE_BRK)
        {
         if(close1 < m.lvl2Qe && close1 < open1)
           {
            m.pendingEntry = NormalizeDouble(low1 - entBuf, _Digits);
            m.stage        = QE_READY_ORDER;
            m.waitOpen930  = esperando930;
            DibujarNivelEstructura("NOVA_" + prefix + "_PE_" + TimeToString(time1), time1, m.pendingEntry, prefix + " PE", clrFireBrick, false);
            if(puedeColocar && !soloReconstruccion)
               ColocarOrdenMotorQe(m, magic, esContinuacion, ORDER_TYPE_SELL_STOP, m.pendingEntry, false, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
           }
         else if(low1 < m.lvl2Qe)
            m.lvl2Qe = low1;
        }
     }
  }

void IntentarArmarPendientesEnEspera(datetime srvTime, datetime nyTime, datetime srvMarketOpen, datetime nyLastEntry,
                                      datetime nyAsiaStart, datetime nyAsiaLastEntry,
                                      datetime srvSessEnd, datetime srvAsiaLastEntry)
  {
   bool enPre8AMPost = (InpObserveFrom7AM && nyTime < nyAsiaStart && !InpArmPre8AMTriggerAt8AM);
   double entBuf     = IndexPtsToPrice(InpEntryBufferPts);

   // Obtener extremo de la vela de apertura 09:30 NY si una señal esperó su cierre
   int shift930   = iBarShift(_Symbol, PERIOD_M5, srvMarketOpen, true);
   double high930 = (shift930 >= 1) ? iHigh(_Symbol, PERIOD_M5, shift930) : iHigh(_Symbol, PERIOD_M5, 1);
   double low930  = (shift930 >= 1) ? iLow(_Symbol, PERIOD_M5, shift930)  : iLow(_Symbol, PERIOD_M5, 1);

   if(InpEnableSetup1 && g_S1.stage == QE_READY_ORDER && g_S1.pendingEntry > 0.0)
     {
      if(enPre8AMPost && !g_S1.pausedByNews && !g_S1.waitOpen930) { g_S1.stage = InpDirect2QeEntry ? QE_WAIT_2QE_PB : QE_WAIT_2QE_BRK; }
      else
        {
         if(g_S1.waitOpen930)
           {
            g_S1.pendingEntry = (g_S1.dir == 1) ? MathMax(g_S1.pendingEntry, NormalizeDouble(high930 + entBuf, _Digits)) :
                                                  MathMin(g_S1.pendingEntry, NormalizeDouble(low930  - entBuf, _Digits));
            g_S1.waitOpen930  = false;
           }
         ENUM_ORDER_TYPE ot = (g_S1.dir == 1) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
         ColocarOrdenMotorQe(g_S1, MAGIC_S1, false, ot, g_S1.pendingEntry, false, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
        }
     }
   if(InpEnableSetup2Cont && g_S2C.stage == QE_READY_ORDER && g_S2C.pendingEntry > 0.0)
     {
      if(enPre8AMPost && !g_S2C.pausedByNews && !g_S2C.waitOpen930) { g_S2C.stage = InpDirect2QeEntry ? QE_WAIT_2QE_PB : QE_WAIT_2QE_BRK; }
      else
        {
         if(g_S2C.waitOpen930)
           {
            g_S2C.pendingEntry = (g_S2C.dir == 1) ? MathMax(g_S2C.pendingEntry, NormalizeDouble(high930 + entBuf, _Digits)) :
                                                    MathMin(g_S2C.pendingEntry, NormalizeDouble(low930  - entBuf, _Digits));
            g_S2C.waitOpen930  = false;
           }
         ENUM_ORDER_TYPE ot = (g_S2C.dir == 1) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
         ColocarOrdenMotorQe(g_S2C, MAGIC_S2_CONT, true, ot, g_S2C.pendingEntry, false, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
        }
     }
   if(InpEnableSetup2Nac && g_S2NStage == S2N_READY_ORDER)
     {
      if(enPre8AMPost && !g_S2NPausedByNews && !g_S2NWaitOpen930) { g_S2NStage = S2N_WAIT_BOS; }
      else
        {
         double ref930 = g_S2NWaitOpen930 ? ((g_S2NDir == 1) ? high930 : low930) : 0.0;
         g_S2NWaitOpen930 = false;
         ConfirmarYColocarS2Nac(iTime(_Symbol, PERIOD_M5, 1), false, ref930, nyTime, nyAsiaStart, srvSessEnd, srvAsiaLastEntry);
        }
     }
  }

void ColocarOrdenMotorQe(QeMachine &m, ulong magic, bool esContinuacion, ENUM_ORDER_TYPE orderType, double entryPrice,
                         bool soloReconstruccion, datetime nyTime, datetime nyAsiaStart, datetime srvSessEnd, datetime srvAsiaLastEntry)
  {
   double slPrice = 0.0;
   double distPct = 0.0;
   double minStop = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   string setupName = esContinuacion ? "S2C" : "S1";

   if(orderType == ORDER_TYPE_BUY_STOP)
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(!soloReconstruccion && ask >= entryPrice - minStop)
        {
         TraceEv("SKIP", setupName, m.dir, entryPrice, ask, 0, 0, "ask ya supero la entrada");
         m.stage = QE_WAIT_2QE_BRK;
         return;
        }

      distPct = ((entryPrice - g_RangeHigh) / g_RangeHigh) * 100.0;
      if(distPct > InpCont_SL_AgresPct)       { slPrice = g_RangeHigh; m.slType = "SL A"; }
      else if(distPct >= InpCont_SL_ModMinPct){ slPrice = g_RangeMid;  m.slType = "SL M"; }
      else                                    { slPrice = g_RangeLow;  m.slType = "SL C"; }
     }
   else
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(!soloReconstruccion && bid <= entryPrice + minStop)
        {
         TraceEv("SKIP", setupName, m.dir, entryPrice, bid, 0, 0, "bid ya supero la entrada");
         m.stage = QE_WAIT_2QE_BRK;
         return;
        }

      distPct = ((g_RangeLow - entryPrice) / g_RangeLow) * 100.0;
      if(distPct > InpCont_SL_AgresPct)       { slPrice = g_RangeLow;  m.slType = "SL A"; }
      else if(distPct >= InpCont_SL_ModMinPct){ slPrice = g_RangeMid;  m.slType = "SL M"; }
      else                                    { slPrice = g_RangeHigh; m.slType = "SL C"; }
     }

   slPrice = NormalizeDouble(slPrice, _Digits);
   double distSL = MathAbs(entryPrice - slPrice);
   if(distSL <= _Point) return;

   // v3.15 Fuga 1: SL lado incorrecto (direccion vieja revivida en Asia) -> FINISHED, sin reintento por tick
   bool slInvalido = (orderType == ORDER_TYPE_BUY_STOP) ? (slPrice >= entryPrice - minStop) : (slPrice <= entryPrice + minStop);
   if(slInvalido && !soloReconstruccion)
     {
      TraceEv("SKIP", setupName, m.dir, entryPrice, slPrice, 0, 0, "SL lado incorrecto -> FINISHED");
      m.stage = QE_FINISHED;
      return;
     }

   m.initRisk     = distSL;
   m.maxRRReached = 0.0;
   if(soloReconstruccion) { m.stage = QE_ORDER_ACTIVE; return; }

   double tpR     = esContinuacion ? InpTP_R_S2C : InpTP_R_S1;
   double tpPrice = (orderType == ORDER_TYPE_BUY_STOP) ?
                    NormalizeDouble(entryPrice + distSL * tpR, _Digits) :
                    NormalizeDouble(entryPrice - distSL * tpR, _Digits);

   bool inAsia = (InpEnableAsiaSession && nyTime >= nyAsiaStart);
   string comment = esContinuacion ?
                    ((orderType == ORDER_TYPE_BUY_STOP) ? "NOVA_S2_CONT_BUY" : "NOVA_S2_CONT_SELL") :
                    ((orderType == ORDER_TYPE_BUY_STOP) ? "NOVA_S1_BUY" : "NOVA_S1_SELL");

   if(EnviarOrdenStop(magic, setupName, m.dir, orderType, entryPrice, slPrice, tpPrice,
                      inAsia ? srvAsiaLastEntry : srvSessEnd, comment))
     {
      m.stage        = QE_ORDER_ACTIVE;
      m.orderInAsia  = inAsia;
      m.pausedByNews = false;
      m.waitOpen930  = false;
      GuardarMetadataGV(g_ActiveDayKey, magic, m.initRisk, m.maxRRReached, m.slType, m.tradesToday, inAsia);
     }
  }

bool EnviarOrdenStop(ulong magic, string setupName, int dir, ENUM_ORDER_TYPE orderType,
                     double entryPrice, double slPrice, double tpPrice, datetime srvExpiry, string comment)
  {
   double lotes = CalcularLotajePorRiesgo(MathAbs(entryPrice - slPrice), entryPrice, slPrice, orderType, setupName, dir);
   if(lotes <= 0.0) return false;

   double marginReq = 0.0;
   ENUM_ORDER_TYPE marginType = (orderType == ORDER_TYPE_BUY_STOP || orderType == ORDER_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(OrderCalcMargin(marginType, _Symbol, lotes, entryPrice, marginReq))
     {
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      if(marginReq > freeMargin * 0.95)
        {
         TraceEv("SKIP", setupName, dir, entryPrice, slPrice, marginReq, freeMargin, "Margen libre insuficiente");
         return false;
        }
     }

   ENUM_ORDER_TYPE_TIME timeType = ORDER_TIME_GTC;
   datetime expTime = 0;
   long expModes = SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_MODE);
   if((expModes & SYMBOL_EXPIRATION_SPECIFIED) != 0 && srvExpiry > TimeCurrent() + 60)
     {
      timeType = ORDER_TIME_SPECIFIED;
      expTime  = srvExpiry;
     }

   trade.SetExpertMagicNumber(magic);
   if(trade.OrderOpen(_Symbol, orderType, lotes, 0.0, entryPrice, slPrice, tpPrice, timeType, expTime, comment))
     {
      double distSL = MathAbs(entryPrice - slPrice);
      TraceEv("ORDER", setupName, dir, entryPrice, slPrice, tpPrice, lotes,
              "R=" + Fmt(distSL) + " exp=" + EnumToString(timeType));
      return true;
     }

   TraceEv("REJECT", setupName, dir, entryPrice, slPrice, tpPrice, lotes,
           "ret=" + IntegerToString(trade.ResultRetcode()) + " " + trade.ResultRetcodeDescription());
   return false;
  }

//+------------------------------------------------------------------+
//| 9. GESTIÓN ACTIVA DE POSICIONES Y CUMPLIMIENTO BULLFY            |
//+------------------------------------------------------------------+
double ObtenerComisionPosicion(ulong posIdentifier)
  {
   if(!HistorySelectByPosition((long)posIdentifier)) return 0.0;
   double comm = 0.0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong dt = HistoryDealGetTicket(i);
      comm += HistoryDealGetDouble(dt, DEAL_COMMISSION);
     }
   return comm;
  }

bool PuedeCerrarOModificarPorBullfy(ulong ticket, datetime srvTime, datetime nyTime)
  {
   if(!InpUseNewsFilter) return true;
   if(ArraySize(g_NewsList) == 0) return true;
   if(!EstaEnVentanaRestringidaBullfy(nyTime, 30)) return true; // 30s de margen de seguridad

   if(!PositionSelectByTicket(ticket)) return false;
   datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
   long ageSec       = (long)(srvTime - openTime);

   ulong posId  = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
   double netPnL = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + ObtenerComisionPosicion(posId);

   // Zona gris cerca de BE: exigir 24h por seguridad absoluta
   if(MathAbs(netPnL) < 5.0)
      return (ageSec >= 86460);

   if(netPnL < 0.0)
      return (ageSec >= 3660);  // >= 60 minutos completos (con 60s de colchón)

   return (ageSec >= 86460);    // >= 24 horas completas (con 60s de colchón)
  }

bool ExpiroVentanaPendiente(datetime nyTime, bool orderInAsia, datetime nyLastEntry, datetime nyAsiaStart, datetime nyAsiaLastEntry)
  {
   if(!orderInAsia)
     {
      if(nyTime > nyLastEntry) return true;
     }
   else
     {
      if(nyTime < nyAsiaStart || nyTime > nyAsiaLastEntry) return true;
     }
   return false;
  }

int BuscarIndiceCarryover(ulong ticket)
  {
   for(int i = 0; i < ArraySize(g_CarryPos); i++)
      if(g_CarryPos[i].ticket == ticket) return i;
   return -1;
  }

void CapturarPosicionesAlCambioDeDia()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      ulong mg = (ulong)PositionGetInteger(POSITION_MAGIC);
      if(mg != MAGIC_S1 && mg != MAGIC_S2_NAC && mg != MAGIC_S2_CONT) continue;
      if(BuscarIndiceCarryover(ticket) >= 0) continue;

      CarryoverPos cp;
      cp.ticket       = ticket;
      cp.magic        = mg;
      cp.setupName    = (mg == MAGIC_S1) ? "S1" : ((mg == MAGIC_S2_CONT) ? "S2C" : "S2N");
      cp.initRisk     = 0.0;
      cp.maxRRReached = 0.0;
      cp.open930Done  = true;
      cp.graceDone    = false;
      cp.inAsia       = false;

      if(mg == MAGIC_S1 && g_S1.initRisk > 0.0)
        {
         cp.initRisk = g_S1.initRisk; cp.maxRRReached = g_S1.maxRRReached;
         cp.open930Done = g_S1.open930Done; cp.graceDone = g_S1.graceDone; cp.inAsia = g_S1.orderInAsia;
        }
      else if(mg == MAGIC_S2_CONT && g_S2C.initRisk > 0.0)
        {
         cp.initRisk = g_S2C.initRisk; cp.maxRRReached = g_S2C.maxRRReached;
         cp.open930Done = g_S2C.open930Done; cp.graceDone = g_S2C.graceDone; cp.inAsia = g_S2C.orderInAsia;
        }
      else if(mg == MAGIC_S2_NAC && g_S2NInitRisk > 0.0)
        {
         cp.initRisk = g_S2NInitRisk; cp.maxRRReached = g_S2NMaxRRReached;
         cp.open930Done = g_S2NOpen930Done; cp.graceDone = g_S2NGraceDone; cp.inAsia = g_S2NOrderInAsia;
        }

      if(cp.initRisk <= 0.0)
        {
         string dummySL = "";
         ulong posId = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
         cp.initRisk = RecuperarInitRiskDesdeHistorial(ticket, posId, PositionGetDouble(POSITION_PRICE_OPEN),
                                                       PositionGetDouble(POSITION_SL), g_ActiveDayKey, mg,
                                                       dummySL, cp.maxRRReached, cp.inAsia);
        }

      int n = ArraySize(g_CarryPos);
      ArrayResize(g_CarryPos, n + 1);
      g_CarryPos[n] = cp;
     }
  }

void GestionarPosicionesArrastradas(datetime nyTime, datetime srvTime, datetime srvDayStart)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      ulong mg = (ulong)PositionGetInteger(POSITION_MAGIC);
      if(mg != MAGIC_S1 && mg != MAGIC_S2_NAC && mg != MAGIC_S2_CONT) continue;
      if((datetime)PositionGetInteger(POSITION_TIME) >= srvDayStart) continue;

      int idx = BuscarIndiceCarryover(ticket);
      if(idx < 0)
        {
         CarryoverPos cp;
         cp.ticket       = ticket;
         cp.magic        = mg;
         cp.setupName    = (mg == MAGIC_S1) ? "S1" : ((mg == MAGIC_S2_CONT) ? "S2C" : "S2N");
         cp.maxRRReached = 0.0;
         cp.open930Done  = true;
         cp.graceDone    = false;
         cp.inAsia       = false;
         string dummySL  = "";
         ulong posId     = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
         cp.initRisk     = RecuperarInitRiskDesdeHistorial(ticket, posId, PositionGetDouble(POSITION_PRICE_OPEN),
                                                           PositionGetDouble(POSITION_SL), 0, mg,
                                                           dummySL, cp.maxRRReached, cp.inAsia);
         idx = ArraySize(g_CarryPos);
         ArrayResize(g_CarryPos, idx + 1);
         g_CarryPos[idx] = cp;
        }

      trade.SetExpertMagicNumber(mg);
      GestionarPosicionComun(ticket, mg, g_CarryPos[idx].setupName, nyTime, srvTime,
                             g_CarryPos[idx].initRisk, g_CarryPos[idx].maxRRReached,
                             g_CarryPos[idx].open930Done, g_CarryPos[idx].graceDone, g_CarryPos[idx].inAsia);
     }

   // Limpiar registros de posiciones arrastradas ya cerradas
   for(int k = ArraySize(g_CarryPos) - 1; k >= 0; k--)
     {
      if(!PositionSelectByTicket(g_CarryPos[k].ticket))
        {
         int last = ArraySize(g_CarryPos) - 1;
         if(k < last) g_CarryPos[k] = g_CarryPos[last];
         ArrayResize(g_CarryPos, last);
        }
     }
  }

void GestionarMotorQe(QeMachine &m, ulong magic, string setupName, datetime nyTime, datetime srvTime, datetime srvDayStart,
                      bool esContinuacion, datetime nyLastEntry, datetime nyAsiaStart, datetime nyAsiaLastEntry)
  {
   trade.SetExpertMagicNumber(magic);

   bool tienePendiente = false;
   double closePrev = iClose(_Symbol, PERIOD_M5, 1);
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == magic)
        {
         tienePendiente = true;
         bool invalidadoOpuesto = (m.dir == 1 && closePrev > 0.0 && closePrev < g_RangeLow) ||
                                  (m.dir == -1 && closePrev > 0.0 && closePrev > g_RangeHigh);
         bool expiro = ExpiroVentanaPendiente(nyTime, m.orderInAsia, nyLastEntry, nyAsiaStart, nyAsiaLastEntry);
         if(expiro || invalidadoOpuesto)
           {
            trade.OrderDelete(ticket);
            tienePendiente = false;
            m.stage = QE_FINISHED;
           }
        }
     }

   bool tienePosicion = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol && (ulong)PositionGetInteger(POSITION_MAGIC) == magic)
        {
         // Las posiciones abiertas antes de las 00:00 NY de hoy pertenecen a la sesión previa y se gestionan aparte
         if((datetime)PositionGetInteger(POSITION_TIME) < srvDayStart) continue;

         tienePosicion = true;
         bool esNuevaPos = (m.stage != QE_IN_TRADE);
         if(esNuevaPos)
           {
            m.stage        = QE_IN_TRADE;
            if(m.dir == 0)
               m.dir = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
            m.tradesToday++;
            m.graceDone    = false;
            m.open930Done  = false;
            m.maxRRReached = 0.0;
            if(m.initRisk <= 0.0)
              {
               ulong posId = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
               m.initRisk = RecuperarInitRiskDesdeHistorial(ticket, posId, PositionGetDouble(POSITION_PRICE_OPEN),
                                                            PositionGetDouble(POSITION_SL), g_ActiveDayKey, magic,
                                                            m.slType, m.maxRRReached, m.orderInAsia);
              }
            TraceEv("FILL", setupName, m.dir, PositionGetDouble(POSITION_PRICE_OPEN), PositionGetDouble(POSITION_SL),
                    PositionGetDouble(POSITION_TP), m.initRisk, "ticket=" + IntegerToString((long)ticket));
            GuardarMetadataGV(g_ActiveDayKey, magic, m.initRisk, m.maxRRReached, m.slType, m.tradesToday, m.orderInAsia);
           }

         bool cerraron = GestionarPosicionComun(ticket, magic, setupName, nyTime, srvTime,
                                                m.initRisk, m.maxRRReached, m.open930Done, m.graceDone, m.orderInAsia);
         if(cerraron)
           {
            bool puedeReentrar = (m.tradesToday < 2 &&
                                  ((!m.orderInAsia && nyTime <= nyLastEntry) || (m.orderInAsia && nyTime <= nyAsiaLastEntry)));
            if(puedeReentrar)
              {
               if(InpDirect2QeEntry)
                 {
                  double recExt = m.lvl2Qe;
                  if(m.dir == 1)
                    {
                     double hArr[];
                     if(CopyHigh(_Symbol, PERIOD_M5, 1, 12, hArr) > 0)
                        recExt = MathMax(recExt, hArr[ArrayMaximum(hArr)]);
                    }
                  else
                    {
                     double lArr[];
                     if(CopyLow(_Symbol, PERIOD_M5, 1, 12, lArr) > 0)
                        recExt = MathMin(recExt, lArr[ArrayMinimum(lArr)]);
                    }
                  m.extreme = recExt;
                  m.pbCount = 0;
                  m.stage   = QE_WAIT_2QE_PB;
                 }
               else
                 {
                  double c1 = iClose(_Symbol, PERIOD_M5, 1);
                  m.lvl2Qe  = (m.dir == 1) ? MathMax(m.lvl2Qe, c1) : MathMin(m.lvl2Qe, c1);
                  m.stage   = QE_WAIT_2QE_BRK;
                 }
              }
            else
               m.stage = QE_FINISHED;
            continue;
           }
         GuardarMetadataGV(g_ActiveDayKey, magic, m.initRisk, m.maxRRReached, m.slType, m.tradesToday, m.orderInAsia);
        }
     }

   if(!tienePosicion && !tienePendiente && !m.pausedByNews && !m.waitOpen930 && (m.stage == QE_IN_TRADE || m.stage == QE_ORDER_ACTIVE))
      m.stage = QE_FINISHED;
  }

void GestionarSetup2Nacimiento(datetime nyTime, datetime srvTime, datetime srvDayStart, datetime nyLastEntry, datetime nyAsiaStart, datetime nyAsiaLastEntry)
  {
   trade.SetExpertMagicNumber(MAGIC_S2_NAC);

   bool tienePendiente = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == MAGIC_S2_NAC)
        {
         tienePendiente = true;
         double curBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double curAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double protExt = (g_S2NProtectedExtreme > 0.0) ? g_S2NProtectedExtreme : g_S2NExtreme;
         bool invalidado = (g_S2NDir == 1 && curBid < protExt) || (g_S2NDir == -1 && curAsk > protExt);
         bool expiro     = ExpiroVentanaPendiente(nyTime, g_S2NOrderInAsia, nyLastEntry, nyAsiaStart, nyAsiaLastEntry);

         if(expiro || invalidado)
           {
            trade.OrderDelete(ticket);
            tienePendiente = false;
            g_S2NStage = expiro ? S2N_FINISHED : S2N_WAIT_CH;
           }
        }
     }

   bool tienePosicion = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol && (ulong)PositionGetInteger(POSITION_MAGIC) == MAGIC_S2_NAC)
        {
         if((datetime)PositionGetInteger(POSITION_TIME) < srvDayStart) continue;

         tienePosicion = true;
         bool esNuevaPos = (g_S2NStage != S2N_IN_TRADE);
         if(esNuevaPos)
           {
            g_S2NStage        = S2N_IN_TRADE;
            if(g_S2NDir == 0)
               g_S2NDir = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
            g_S2NTradesToday++;
            g_S2NGraceDone    = false;
            g_S2NOpen930Done  = false;
            g_S2NMaxRRReached = 0.0;
            if(g_S2NInitRisk <= 0.0)
              {
               ulong posId = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
               g_S2NInitRisk = RecuperarInitRiskDesdeHistorial(ticket, posId, PositionGetDouble(POSITION_PRICE_OPEN),
                                                               PositionGetDouble(POSITION_SL), g_ActiveDayKey, MAGIC_S2_NAC,
                                                               g_S2NSLType, g_S2NMaxRRReached, g_S2NOrderInAsia);
              }
            TraceEv("FILL", "S2N", g_S2NDir, PositionGetDouble(POSITION_PRICE_OPEN), PositionGetDouble(POSITION_SL),
                    PositionGetDouble(POSITION_TP), g_S2NInitRisk, "ticket=" + IntegerToString((long)ticket));
            GuardarMetadataGV(g_ActiveDayKey, MAGIC_S2_NAC, g_S2NInitRisk, g_S2NMaxRRReached, g_S2NSLType, g_S2NTradesToday, g_S2NOrderInAsia);
           }

         bool cerraron = GestionarPosicionComun(ticket, MAGIC_S2_NAC, "S2N", nyTime, srvTime,
                                                g_S2NInitRisk, g_S2NMaxRRReached, g_S2NOpen930Done, g_S2NGraceDone, g_S2NOrderInAsia);
         if(cerraron)
           {
            g_S2NStage = S2N_FINISHED;
            continue;
           }
         GuardarMetadataGV(g_ActiveDayKey, MAGIC_S2_NAC, g_S2NInitRisk, g_S2NMaxRRReached, g_S2NSLType, g_S2NTradesToday, g_S2NOrderInAsia);
        }
     }

   if(!tienePosicion && !tienePendiente && !g_S2NPausedByNews && !g_S2NWaitOpen930 && (g_S2NStage == S2N_IN_TRADE || g_S2NStage == S2N_ORDER_ACTIVE))
      g_S2NStage = S2N_FINISHED;
  }

bool GestionarPosicionComun(ulong ticket, ulong magic, string setupName, datetime nyTime, datetime srvTime,
                            double initRisk, double &maxRRReached, bool &open930Done, bool &graceDone, bool inAsia)
  {
   if(!PositionSelectByTicket(ticket)) return false;

   long     posType   = PositionGetInteger(POSITION_TYPE);
   double   openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double   curSL     = PositionGetDouble(POSITION_SL);
   double   curTP     = PositionGetDouble(POSITION_TP);
   datetime openTime  = (datetime)PositionGetInteger(POSITION_TIME);

   double curPrice  = (posType == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double diffPrice = (posType == POSITION_TYPE_BUY) ? (curPrice - openPrice) : (openPrice - curPrice);

   // Si por algún motivo initRisk no existiera, nunca asumir RR = 0 falso
   if(initRisk <= 0.0) return false;

   double currentRR = diffPrice / initRisk;
   if(currentRR > maxRRReached) maxRRReached = currentRR;

   int dirPos = (posType == POSITION_TYPE_BUY) ? 1 : -1;

   MqlDateTime dt;
   TimeToStruct(nyTime, dt);
   int minsNY      = dt.hour * 60 + dt.min;
   int minsClose15 = InpSessionEndHour * 60 + InpSessionEndMin - 5; // 15:40 NY
   int minsAbierto = (int)((srvTime - openTime) / 60);

   bool bullfyOk = PuedeCerrarOModificarPorBullfy(ticket, srvTime, nyTime);

   // 1. Regla Apertura Americana 09:29-09:30 NY
   if(InpExit_Open930 && InpFilter930Open && !open930Done && minsNY >= (9 * 60 + 29) && minsNY <= (9 * 60 + 30))
     {
      open930Done = true;
      if(currentRR >= -0.15 && currentRR <= 0.05)
        {
         if(bullfyOk && trade.PositionClose(ticket))
           {
            TraceEv("EXIT", setupName, dirPos, curPrice, openPrice, currentRR, 0, "OPEN_930_BE ticket=" + IntegerToString((long)ticket));
            return true;
           }
        }
      else if(currentRR > 0.05 && bullfyOk)
        {
         double protSL = openPrice - dirPos * initRisk * 0.25;
         MoverSLSeguro(ticket, posType, curSL, protSL, curTP, setupName + "_930");
         if(PositionSelectByTicket(ticket)) curSL = PositionGetDouble(POSITION_SL);
        }
     }

   // 2. Regla opcional Cierre 15:40 NY (desactivada por defecto: se monitorea SL en Asia)
   if(InpExit_EndOfDay && InpClose1540Rule && !inAsia && minsNY >= minsClose15 && minsNY <= (minsClose15 + 15) && currentRR <= 0.15)
     {
      if(bullfyOk && trade.PositionClose(ticket))
        {
         TraceEv("EXIT", setupName, dirPos, curPrice, openPrice, currentRR, 0, "CLOSE_1540 ticket=" + IntegerToString((long)ticket));
         return true;
        }
     }

   // 2b. Regla Nocturna / Fin de Asia: asegurar BE o leve positivo antes de dormir (o cierre viernes)
   if(InpExit_EndOfDay && InpProtectAtAsiaEnd && bullfyOk && minsAbierto >= 45)
     {
      int minsBed = InpBedtimeProtectHour * 60 + InpBedtimeProtectMin;
      bool ventanaDormir = (minsNY >= minsBed || minsNY < (InpSessionStartHour * 60)) ||
                           (dt.day_of_week == 5 && minsNY >= (16 * 60 + 30));
      if(ventanaDormir)
        {
         double bedSL = NormalizeDouble(openPrice + dirPos * initRisk * InpBedtimeLockRR, _Digits);
         bool faltaBedSL = (posType == POSITION_TYPE_BUY) ? (curSL < bedSL - _Point) : (curSL == 0.0 || curSL > bedSL + _Point);
         if(faltaBedSL)
           {
            MoverSLSeguro(ticket, posType, curSL, bedSL, curTP, setupName + "_ASIA_BE");
            if(PositionSelectByTicket(ticket)) curSL = PositionGetDouble(POSITION_SL);
           }
        }
     }

   // 3. Regla de los 60 minutos: mitigar SL a -0.25R sin cerrar a mercado (o modo cierre legacy si se activa)
   if(InpExit_Grace && !graceDone && minsAbierto >= InpGracePeriodMins)
     {
      if(InpGraceCloseMarket)
        {
         graceDone = true;
         if(maxRRReached < InpTrail_Step1_TrigRR && currentRR < InpGraceMinRR)
           {
            if(bullfyOk && trade.PositionClose(ticket))
              {
               TraceEv("EXIT", setupName, dirPos, curPrice, openPrice, currentRR, (double)minsAbierto, "GRACE ticket=" + IntegerToString((long)ticket));
               return true;
              }
            else
               graceDone = false;
           }
        }
      else
        {
         double slMitigado = NormalizeDouble(openPrice + dirPos * initRisk * InpGraceMitigateSL_RR, _Digits);
         bool yaMitigado   = (posType == POSITION_TYPE_BUY) ? (curSL >= slMitigado - _Point) : (curSL > 0.0 && curSL <= slMitigado + _Point);
         if(yaMitigado)
            graceDone = true;
         else if(bullfyOk)
           {
            MoverSLSeguro(ticket, posType, curSL, slMitigado, curTP, setupName + "_GRACE_SL025");
            if(PositionSelectByTicket(ticket)) curSL = PositionGetDouble(POSITION_SL);
            yaMitigado = (posType == POSITION_TYPE_BUY) ? (curSL >= slMitigado - _Point) : (curSL > 0.0 && curSL <= slMitigado + _Point);
            if(yaMitigado)
               graceDone = true;
            else
              {
               // Si a los 60m el precio está temporalmente más profundo que -0.25R, ajustar al micro-swing M5 post-entrada y esperar recuperación para fijar -0.25R
               double microSw = InpGraceMicroSwing ? ObtenerSwingPostEntradaM5(posType, openTime, false, 1, 30) : 0.0; // v3.15 Fuga 2
               if(microSw > 0.0)
                 {
                  MoverSLSeguro(ticket, posType, curSL, microSw, curTP, setupName + "_GRACE_SWING");
                  if(PositionSelectByTicket(ticket)) curSL = PositionGetDouble(POSITION_SL);
                 }
              }
           }
        }
     }

   // 4. Mitigación Judas (-0.50 RR) para Setup 1 y Setup 2 Continuación
   if(InpEnableJudasCut && setupName != "S2N" && maxRRReached < 0.30 && currentRR <= InpJudasTriggerRR)
     {
      double o1 = iOpen(_Symbol, PERIOD_M5, 1), c1 = iClose(_Symbol, PERIOD_M5, 1);
      bool contraVela = (posType == POSITION_TYPE_BUY) ? (c1 < o1) : (c1 > o1);
      if(contraVela && bullfyOk && trade.PositionClose(ticket))
        {
         TraceEv("EXIT", setupName, dirPos, curPrice, openPrice, currentRR, 0, "JUDAS_CUT ticket=" + IntegerToString((long)ticket));
         return true;
        }
     }

   // 5. Trailing progresivo desacoplado por motor (Qe vs S2 Nacimiento)
   if(InpExit_Trailing && bullfyOk)
     {
      ENUM_TRAIL_MODE mode = (setupName == "S2N") ? InpTrailModeS2N : InpTrailModeQe;
      AplicarTrailingProgresivo(ticket, posType, setupName, mode, openTime, openPrice, curSL, curTP, initRisk, maxRRReached);
     }

   return false;
  }

bool ObtenerATRYCierreM5(double &atrOut, double &close1Out)
  {
   if(g_ATRHandle == INVALID_HANDLE) return false;
   datetime curBar = iTime(_Symbol, PERIOD_M5, 0);
   if(curBar != g_LastATRBarTime || g_CachedATR <= 0.0)
     {
      double atrBuf[];
      ArraySetAsSeries(atrBuf, true);
      if(CopyBuffer(g_ATRHandle, 0, 1, 1, atrBuf) != 1 || atrBuf[0] <= 0.0)
         return false;
      g_CachedATR      = atrBuf[0];
      g_CachedClose1   = iClose(_Symbol, PERIOD_M5, 1);
      g_LastATRBarTime = curBar;
     }
   atrOut    = g_CachedATR;
   close1Out = g_CachedClose1;
   return (atrOut > 0.0 && close1Out > 0.0);
  }

void AplicarTrailingProgresivo(ulong ticket, long posType, string setupName, ENUM_TRAIL_MODE trailMode, datetime openTime,
                               double openPrice, double curSL, double curTP, double initRisk, double maxRRReached)
  {
   int dir        = (posType == POSITION_TYPE_BUY) ? 1 : -1;
   double floorSL = 0.0;
   string reason  = "";
   bool usarSwing = false;
   bool usarATR   = false;

   if(trailMode == TRAIL_M5_SWING)
     {
      if(maxRRReached >= InpTrail_Step1_TrigRR)
        {
         floorSL = openPrice + dir * initRisk * InpTrail_Step1_SL_RR;
         reason  = setupName + "_RR0.50";
        }

      if(maxRRReached >= InpSoftFloor_TrigRR) // v3.15 Fuga 3: piso suave
        {
         floorSL = openPrice + dir * initRisk * InpSoftFloor_SL_RR;
         reason  = setupName + "_SOFT_FLOOR";
        }

      double stepFloorSL     = floorSL;
      double targetSL        = stepFloorSL;
      bool   haySwingSobreBE = false;

      if(maxRRReached >= InpManualSwing_StartRR)
        {
         bool reqBOS = InpManualSwing_RequireBOS && (maxRRReached < InpManualSwing_NoBOSFromRR);
         double swSL = ObtenerSwingPostEntradaM5(posType, openTime, reqBOS, InpSwingFractalBars, InpSwingLookbackBars);
         if(swSL == 0.0 && !reqBOS && InpManualSwing_RequireBOS)
            swSL = ObtenerSwingPostEntradaM5(posType, openTime, true, InpSwingFractalBars, InpSwingLookbackBars);

         if(swSL > 0.0)
           {
            haySwingSobreBE = (posType == POSITION_TYPE_BUY) ? (swSL > openPrice) : (swSL < openPrice);
            bool mejoraPiso = (stepFloorSL == 0.0) ||
                              ((posType == POSITION_TYPE_BUY) ? (swSL > stepFloorSL) : (swSL < stepFloorSL));
            if(mejoraPiso)
              {
               targetSL = swSL;
               reason   = setupName + "_M5_SWING";
              }
           }
        }

      // Respaldo ATR exclusivo para impulsos verticales >= 2.0R donde aún no se formó ningún swing M5 sobre BE
      if(InpManualSwing_UseATRFallback && maxRRReached >= InpManualSwing_FreeAboveRR && !haySwingSobreBE && g_ATRHandle != INVALID_HANDLE)
        {
         double atrVal = 0.0, close1Val = 0.0;
         if(ObtenerATRYCierreM5(atrVal, close1Val))
           {
            double multATR = MathMax(2.5, InpTrailX_ATRMult);
            double atrSL   = NormalizeDouble(close1Val - dir * multATR * atrVal, _Digits);
            bool mejora    = (targetSL == 0.0) ||
                             ((posType == POSITION_TYPE_BUY) ? (atrSL > targetSL) : (atrSL < targetSL));
            if(mejora)
              {
               targetSL = atrSL;
               reason   = setupName + "_ATR_VERT";
              }
           }
        }

      if(targetSL > 0.0)
         MoverSLSeguro(ticket, posType, curSL, targetSL, curTP, reason);
      return;
     }
   else if(trailMode == TRAIL_NOVA_SWING)
     {
      if(maxRRReached >= InpTrail_Step3_TrigRR)
        {
         floorSL = openPrice + dir * initRisk * InpTrail_Step3_SL_RR;
         reason  = setupName + "_RR1.80";
        }
      else if(maxRRReached >= InpTrail_Step2_TrigRR)
        {
         floorSL = openPrice + dir * initRisk * InpTrail_Step2_SL_RR;
         reason  = setupName + "_RR0.80";
        }
      else if(maxRRReached >= InpTrail_Step1_TrigRR)
        {
         floorSL = openPrice + dir * initRisk * InpTrail_Step1_SL_RR;
         reason  = setupName + "_RR0.50";
        }

      if(maxRRReached >= InpTrail_SwingStartRR)
         usarSwing = true;
     }
   else if(trailMode == TRAIL_ATR_SWING)
     {
      if(maxRRReached >= InpTrailX_Step5_TrigRR)      { floorSL = openPrice + dir * initRisk * InpTrailX_Step5_SL_RR; reason = setupName + "_X1.80"; }
      else if(maxRRReached >= InpTrailX_Step4_TrigRR) { floorSL = openPrice + dir * initRisk * InpTrailX_Step4_SL_RR; reason = setupName + "_X1.50"; }
      else if(maxRRReached >= InpTrailX_Step3_TrigRR) { floorSL = openPrice + dir * initRisk * InpTrailX_Step3_SL_RR; reason = setupName + "_X1.20"; }
      else if(maxRRReached >= InpTrail_Step2_TrigRR)  { floorSL = openPrice + dir * initRisk * InpTrail_Step2_SL_RR;  reason = setupName + "_RR0.80"; }
      else if(maxRRReached >= InpTrail_Step1_TrigRR)  { floorSL = openPrice + dir * initRisk * InpTrail_Step1_SL_RR;  reason = setupName + "_RR0.50"; }

      if(maxRRReached >= InpTrailX_SwingStartRR)
         usarSwing = true;
      if(maxRRReached >= InpTrailX_ATRStartRR && g_ATRHandle != INVALID_HANDLE)
         usarATR = true;
     }
   else // TRAIL_OPTIMIZED
     {
      if(maxRRReached >= 1.50)      { floorSL = openPrice + dir * initRisk * 1.00; reason = setupName + "_OPT1.50"; }
      else if(maxRRReached >= 1.00) { floorSL = openPrice + dir * initRisk * 0.50; reason = setupName + "_OPT1.00"; }
      else if(maxRRReached >= 0.65) { floorSL = openPrice;                          reason = setupName + "_OPT0.65"; }

      if(maxRRReached >= 2.00)
         usarSwing = true;
     }

   double stepFloorSL     = floorSL;
   double targetSL          = stepFloorSL;
   bool   haySwingSobrePiso = false;

   if(usarSwing)
     {
      double swingSL = ObtenerSwingEstructuralM5(posType, InpSwingFractalBars, InpSwingLookbackBars);
      if(swingSL > 0.0)
        {
         if(stepFloorSL == 0.0)
           {
            haySwingSobrePiso = (posType == POSITION_TYPE_BUY) ? (swingSL > openPrice) : (swingSL < openPrice);
            targetSL          = swingSL;
            reason            = setupName + "_SWING";
           }
         else
           {
            haySwingSobrePiso = (posType == POSITION_TYPE_BUY) ? (swingSL > stepFloorSL) : (swingSL < stepFloorSL);
            if(haySwingSobrePiso)
              {
               targetSL = swingSL;
               reason   = setupName + "_SWING";
              }
           }
        }
     }

   // Respaldo ATR: si InpTrailX_ATROnlyWithoutSwing = true, solo actúa cuando aún NO hay swing fractal sobre el piso
   if(usarATR && (!InpTrailX_ATROnlyWithoutSwing || !haySwingSobrePiso))
     {
      double atrVal = 0.0, close1Val = 0.0;
      if(ObtenerATRYCierreM5(atrVal, close1Val))
        {
         double refPx = InpTrailX_ATROnBarClose ? close1Val :
                        ((posType == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK));
         if(refPx > 0.0)
           {
            double atrSL = NormalizeDouble(refPx - dir * InpTrailX_ATRMult * atrVal, _Digits);
            bool mejora  = (targetSL == 0.0) ||
                           ((posType == POSITION_TYPE_BUY) ? (atrSL > targetSL) : (atrSL < targetSL));
            if(mejora)
              {
               targetSL = atrSL;
               reason   = setupName + "_ATR";
              }
           }
        }
     }

   if(targetSL > 0.0)
      MoverSLSeguro(ticket, posType, curSL, targetSL, curTP, reason);
  }

double ObtenerSwingPostEntradaM5(long posType, datetime openTime, bool requireBOS, int fractalBars, int lookbackBars)
  {
   int fBars = MathMax(1, fractalBars);
   int pSec  = PeriodSeconds(PERIOD_M5);
   if(pSec <= 0) pSec = 300;

   datetime entryBarTime      = openTime - (openTime % pSec);
   datetime lastClosedBarTime = iTime(_Symbol, PERIOD_M5, 1);
   if(lastClosedBarTime <= entryBarTime) return 0.0;

   int approxBars = (int)((lastClosedBarTime - entryBarTime) / pSec) + fBars + 4;
   int maxCopy    = MathMin(300, MathMax(approxBars, MathMax(fBars * 2 + 5, lookbackBars)));

   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, PERIOD_M5, 1, maxCopy, rates);
   if(copied <= fBars * 2) return 0.0;

   int lastPostIdx = -1;
   for(int idx = 0; idx < copied; idx++)
     {
      if(rates[idx].time > entryBarTime)
         lastPostIdx = idx;
      else
         break;
     }
   if(lastPostIdx < fBars) return 0.0;

   int entryAndPreLimit = MathMin(copied - 1, lastPostIdx + 1);
   double buf = IndexPtsToPrice(InpSLBufferPts);

   if(posType == POSITION_TYPE_BUY)
     {
      for(int i = fBars; i <= lastPostIdx; i++)
        {
         if(i + fBars >= copied) break;
         bool esSwing = true;
         for(int k = 1; k <= fBars; k++)
           {
            if(rates[i].low > rates[i - k].low || rates[i].low > rates[i + k].low)
              { esSwing = false; break; }
           }
         if(!esSwing) continue;

         if(requireBOS)
           {
            double prePeak = rates[i + 1].high;
            for(int p = i + 1; p <= entryAndPreLimit; p++)
               if(rates[p].high > prePeak) prePeak = rates[p].high;

            bool bosOk = false;
            for(int j = 0; j < i; j++)
              {
               if(rates[j].close > prePeak) { bosOk = true; break; }
              }
            if(!bosOk) continue;
           }
         return NormalizeDouble(rates[i].low - buf, _Digits);
        }
      return 0.0;
     }
   else
     {
      for(int i = fBars; i <= lastPostIdx; i++)
        {
         if(i + fBars >= copied) break;
         bool esSwing = true;
         for(int k = 1; k <= fBars; k++)
           {
            if(rates[i].high < rates[i - k].high || rates[i].high < rates[i + k].high)
              { esSwing = false; break; }
           }
         if(!esSwing) continue;

         if(requireBOS)
           {
            double preTrough = rates[i + 1].low;
            for(int p = i + 1; p <= entryAndPreLimit; p++)
               if(rates[p].low < preTrough) preTrough = rates[p].low;

            bool bosOk = false;
            for(int j = 0; j < i; j++)
              {
               if(rates[j].close < preTrough) { bosOk = true; break; }
              }
            if(!bosOk) continue;
           }
         return NormalizeDouble(rates[i].high + buf, _Digits);
        }
      return 0.0;
     }
  }

double ObtenerSwingEstructuralM5(long posType, int fractalBars, int lookbackBars)
  {
   int fBars  = MathMax(1, fractalBars);
   int lbBars = MathMax(fBars * 2 + 3, lookbackBars);
   double buf = IndexPtsToPrice(InpSLBufferPts);

   if(posType == POSITION_TYPE_BUY)
     {
      double lows[];
      ArraySetAsSeries(lows, true);
      int copied = CopyLow(_Symbol, PERIOD_M5, 1, lbBars, lows);
      if(copied <= fBars * 2) return 0.0;

      for(int i = fBars; i < copied - fBars; i++)
        {
         bool esSwing = true;
         for(int k = 1; k <= fBars; k++)
           {
            if(lows[i] > lows[i - k] || lows[i] > lows[i + k]) { esSwing = false; break; }
           }
         if(esSwing)
            return NormalizeDouble(lows[i] - buf, _Digits);
        }
      return 0.0; // Sin fallback de 6 velas brutas para no ahorcar impulsos verticales
     }
   else
     {
      double highs[];
      ArraySetAsSeries(highs, true);
      int copied = CopyHigh(_Symbol, PERIOD_M5, 1, lbBars, highs);
      if(copied <= fBars * 2) return 0.0;

      for(int i = fBars; i < copied - fBars; i++)
        {
         bool esSwing = true;
         for(int k = 1; k <= fBars; k++)
           {
            if(highs[i] < highs[i - k] || highs[i] < highs[i + k]) { esSwing = false; break; }
           }
         if(esSwing)
            return NormalizeDouble(highs[i] + buf, _Digits);
        }
      return 0.0; // Sin fallback de 6 velas brutas para no ahorcar impulsos verticales
     }
  }

void MoverSLSeguro(ulong ticket, long posType, double curSL, double newSL, double curTP, string reason = "")
  {
   newSL = NormalizeDouble(newSL, _Digits);
   double minStop   = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double freezeLvl = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * _Point;
   double reqDist   = MathMax(minStop, freezeLvl);

   if(posType == POSITION_TYPE_BUY)
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if((curSL == 0.0 || newSL > curSL + _Point) && newSL < (bid - reqDist) &&
         (curSL == 0.0 || MathAbs(bid - curSL) > freezeLvl))
        {
         bool ok = trade.PositionModify(ticket, newSL, curTP);
         TraceEv(ok ? "SLMOVE" : "SLFAIL", reason, 1, newSL, curSL, bid, 0,
                 ok ? "" : "ret=" + IntegerToString(trade.ResultRetcode()) + " " + trade.ResultRetcodeDescription());
        }
     }
   else
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if((curSL == 0.0 || newSL < curSL - _Point) && newSL > (ask + reqDist) &&
         (curSL == 0.0 || MathAbs(curSL - ask) > freezeLvl))
        {
         bool ok = trade.PositionModify(ticket, newSL, curTP);
         TraceEv(ok ? "SLMOVE" : "SLFAIL", reason, -1, newSL, curSL, ask, 0,
                 ok ? "" : "ret=" + IntegerToString(trade.ResultRetcode()) + " " + trade.ResultRetcodeDescription());
        }
     }
  }

//+------------------------------------------------------------------+
//| 10. BLOQUEOS, NOTICIAS, FOMC, RIESGO DIARIO Y RANGO              |
//+------------------------------------------------------------------+
void ActualizarGuardiaDrawdownDiario(datetime nyTime)
  {
   if(!InpUseDailyDDGuard || g_DailyDDBreached || g_DayStartBalance <= 0.0) return;
   double curEq     = AccountInfoDouble(ACCOUNT_EQUITY);
   double refBase   = MathMax(g_DayStartBalance, g_DayStartEquity);
   double ddPct     = ((refBase - curEq) / refBase) * 100.0;
   if(ddPct >= InpMaxDailyLossPct)
     {
      g_DailyDDBreached = true;
      TraceEv("BLOCK", "DD_DAY", 0, curEq, refBase, ddPct, InpMaxDailyLossPct,
              "Limite perdida diaria preventiva alcanzado");
     }
  }

void PausarPendientesPorBloqueo()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol)
        {
         ulong mg = (ulong)OrderGetInteger(ORDER_MAGIC);
         if(mg == MAGIC_S1 || mg == MAGIC_S2_NAC || mg == MAGIC_S2_CONT)
           {
            if(trade.OrderDelete(ticket))
              {
               if(mg == MAGIC_S1 && g_S1.stage == QE_ORDER_ACTIVE)
                 { g_S1.pausedByNews = true; g_S1.stage = (g_S1.pendingEntry > 0.0) ? QE_READY_ORDER : QE_WAIT_2QE_BRK; }
               else if(mg == MAGIC_S2_CONT && g_S2C.stage == QE_ORDER_ACTIVE)
                 { g_S2C.pausedByNews = true; g_S2C.stage = (g_S2C.pendingEntry > 0.0) ? QE_READY_ORDER : QE_WAIT_2QE_BRK; }
               else if(mg == MAGIC_S2_NAC && g_S2NStage == S2N_ORDER_ACTIVE)
                 { g_S2NPausedByNews = true; g_S2NStage = S2N_READY_ORDER; }
              }
           }
        }
     }
  }

void CancelarPendientesPorMagic(ulong magic)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == magic)
         trade.OrderDelete(ticket);
     }
  }

void CancelarTodasLasPendientes()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol)
        {
         ulong mg = (ulong)OrderGetInteger(ORDER_MAGIC);
         if(mg == MAGIC_S1 || mg == MAGIC_S2_NAC || mg == MAGIC_S2_CONT)
            trade.OrderDelete(ticket);
        }
     }
  }

void CerrarPosicionesPorFOMC(datetime srvTime, datetime nyTime)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         ulong mg = (ulong)PositionGetInteger(POSITION_MAGIC);
         if(mg == MAGIC_S1 || mg == MAGIC_S2_NAC || mg == MAGIC_S2_CONT)
           {
            if(PuedeCerrarOModificarPorBullfy(ticket, srvTime, nyTime))
              {
               if(trade.PositionClose(ticket))
                  TraceEv("EXIT", "FOMC", 0, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, 0,
                          "Cierre preventivo FOMC ticket=" + IntegerToString((long)ticket));
              }
           }
        }
     }
  }

double CalcularLotajePorRiesgo(double distanciaSL, double entryPrice, double slPrice, ENUM_ORDER_TYPE oType, string setupName, int dir)
  {
   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double riesgoUSD = balance * (InpRiskPercent / 100.0);
   double minLot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(distanciaSL <= 0.0 || stepLot <= 0.0) return 0.0;

   int volDigits = (stepLot < 1.0) ? (int)MathMin(4, MathMax(1, MathRound(-MathLog10(stepLot)))) : 0;

   double valorPorLote = 0.0;
   ENUM_ORDER_TYPE calcType = (oType == ORDER_TYPE_BUY_STOP || oType == ORDER_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double profit1Lot = 0.0;
   if(OrderCalcProfit(calcType, _Symbol, 1.0, entryPrice, slPrice, profit1Lot))
      valorPorLote = MathAbs(profit1Lot);

   if(valorPorLote <= 0.0)
     {
      double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      if(tickSize > 0.0 && tickValue > 0.0)
         valorPorLote = (distanciaSL / tickSize) * tickValue;
     }

   if(valorPorLote <= 0.0) return 0.0;

   double lotesCrudos = riesgoUSD / valorPorLote;
   double lotesNorm   = MathFloor(lotesCrudos / stepLot) * stepLot;

   if(lotesNorm < minLot)
     {
      double realRiskPct = ((minLot * valorPorLote) / balance) * 100.0;
      if(InpSkipIfMinLotExceedsRisk && realRiskPct > InpMaxAllowedRiskPct)
        {
         TraceEv("SKIP", setupName, dir, entryPrice, slPrice, realRiskPct, InpMaxAllowedRiskPct,
                 "Lote minimo excede riesgo maximo permitido");
         return 0.0;
        }
      lotesNorm = minLot;
     }

   if(lotesNorm > maxLot) lotesNorm = maxLot;
   return NormalizeDouble(lotesNorm, volDigits);
  }

bool DivisaEnFiltroNoticias(string countryRaw)
  {
   string ctry = countryRaw;
   StringTrimLeft(ctry);
   StringTrimRight(ctry);
   StringToUpper(ctry);
   if(ctry == "") return false;

   string cfg = InpNewsCurrency;
   StringTrimLeft(cfg);
   StringTrimRight(cfg);
   StringToUpper(cfg);
   if(cfg == "" || cfg == "ALL") return true;

   string tokens[];
   int n = StringSplit(cfg, ',', tokens);
   for(int i = 0; i < n; i++)
     {
      StringTrimLeft(tokens[i]);
      StringTrimRight(tokens[i]);
      if(tokens[i] == "ALL" || tokens[i] == ctry) return true;
     }
   return false;
  }

bool EsTituloFOMC(string titleRaw)
  {
   string t = titleRaw;
   StringToUpper(t);
   return (StringFind(t, "FOMC") >= 0 || StringFind(t, "FEDERAL FUNDS RATE") >= 0);
  }

void ActualizarCalendarioNoticias(bool forzar)
  {
   datetime now = TimeCurrent();
   if(!forzar)
     {
      if(g_LastNewsFetch > 0 && (now - g_LastNewsFetch) < 1800) return;
      if(g_LastNewsAttempt > 0 && (now - g_LastNewsAttempt) < 120) return;
     }

   g_LastNewsAttempt = now;
   string url = "https://nfs.faireconomy.media/ff_calendar_thisweek.xml";
   char post[], result[];
   string headers;
   ResetLastError();
   int res = WebRequest("GET", url, "", "", 5000, post, 0, result, headers);
   if(res == -1)
     {
      g_NewsStatus = (GetLastError() == 4060) ? "Habilitar URL en MT5 (cache)" : "Error red (cache)";
      return;
     }
   if(res != 200)
     {
      g_NewsStatus = "HTTP " + IntegerToString(res) + " (usando cache)";
      return;
     }

   string xml = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   if(StringFind(xml, "<weeklyevents>") < 0 && StringFind(xml, "<event>") < 0)
     {
      g_NewsStatus = "XML inválido (usando cache)";
      return;
     }

   NewsEvent parsed[];
   ArrayResize(parsed, 0);
   int pos = 0;
   int tentativeHigh = 0;

   while(true)
     {
      int evStart = StringFind(xml, "<event>", pos);  if(evStart < 0) break;
      int evEnd   = StringFind(xml, "</event>", evStart); if(evEnd < 0) break;
      string block = StringSubstr(xml, evStart, evEnd - evStart);

      string impact = ExtractTag(block, "impact");
      string ctry   = ExtractTag(block, "country");
      if(impact == "High" && DivisaEnFiltroNoticias(ctry))
        {
         string title  = ExtractTag(block, "title");
         string dStr   = ExtractTag(block, "date");
         string tStr   = ExtractTag(block, "time");
         datetime dtNY = ParseFFDateTime(dStr, tStr);
         if(dtNY > 0)
           {
            int idx = ArraySize(parsed);
            ArrayResize(parsed, idx + 1);
            parsed[idx].timeNY   = dtNY;
            parsed[idx].title    = title;
            parsed[idx].currency = ctry;
            parsed[idx].isFOMC   = EsTituloFOMC(title);
           }
         else
            tentativeHigh++;
        }
      pos = evEnd + 8;
     }

   ArrayResize(g_NewsList, ArraySize(parsed));
   for(int i = 0; i < ArraySize(parsed); i++)
      g_NewsList[i] = parsed[i];

   g_LastNewsFetch = now;
   g_NewsStatus = "OK (" + IntegerToString(ArraySize(g_NewsList)) + " rojas" +
                  (tentativeHigh > 0 ? (", +" + IntegerToString(tentativeHigh) + " tent") : "") + ")";
  }

void CargarNoticiasHistoricasCSV()
  {
   ArrayResize(g_NewsList, 0);
   if(!InpLoadTesterNewsCSV) { g_NewsStatus = "Backtest (CSV off)"; return; }

   int h = FileOpen("ff_news_history.csv", FILE_READ|FILE_CSV|FILE_ANSI|FILE_COMMON, ';');
   if(h == INVALID_HANDLE)
     {
      g_NewsStatus = "Backtest (sin ff_news_history.csv)";
      return;
     }

   while(!FileIsEnding(h))
     {
      string dtStr  = FileReadString(h);
      string ctry   = FileReadString(h);
      string impact = FileReadString(h);
      string title  = FileReadString(h);
      if(dtStr == "" || StringGetCharacter(dtStr, 0) < '0' || StringGetCharacter(dtStr, 0) > '9') continue;

      if(impact == "High" && DivisaEnFiltroNoticias(ctry))
        {
         datetime dtNY = StringToTime(dtStr);
         if(dtNY > 0)
           {
            int idx = ArraySize(g_NewsList);
            ArrayResize(g_NewsList, idx + 1);
            g_NewsList[idx].timeNY   = dtNY;
            g_NewsList[idx].title    = title;
            g_NewsList[idx].currency = ctry;
            g_NewsList[idx].isFOMC   = EsTituloFOMC(title);
           }
        }
     }
   FileClose(h);
   g_NewsStatus = "Backtest CSV (" + IntegerToString(ArraySize(g_NewsList)) + " rojas)";
  }

bool EstaEnVentanaRestringidaBullfy(datetime nyTime, int extraBufferSec)
  {
   if(!InpUseNewsFilter) return false;
   for(int i = 0; i < ArraySize(g_NewsList); i++)
     {
      datetime wStart = g_NewsList[i].timeNY - InpNewsMinsBefore * 60 - extraBufferSec;
      datetime wEnd   = g_NewsList[i].timeNY + InpNewsMinsAfter  * 60 + extraBufferSec;
      if(nyTime >= wStart && nyTime <= wEnd) return true;
     }
   return false;
  }

bool EstaBloqueadoPorNoticias(datetime nyTime)
  {
   if(!InpUseNewsFilter) { g_NewsStatus = "Desactivado"; g_NextNewsInfo = "Filtro apagado"; return false; }

   datetime proximaHora = 0;
   string proximaTitulo = "";
   for(int i = 0; i < ArraySize(g_NewsList); i++)
     {
      if(nyTime >= g_NewsList[i].timeNY - InpNewsMinsBefore * 60 &&
         nyTime <= g_NewsList[i].timeNY + InpNewsMinsAfter  * 60)
        {
         g_NextNewsInfo = "AHORA: " + g_NewsList[i].title;
         return true;
        }
      if(g_NewsList[i].timeNY > nyTime && (proximaHora == 0 || g_NewsList[i].timeNY < proximaHora))
        {
         proximaHora   = g_NewsList[i].timeNY;
         proximaTitulo = g_NewsList[i].title;
        }
     }
   g_NextNewsInfo = (proximaHora > 0) ? TimeToString(proximaHora, TIME_DATE|TIME_MINUTES) + " NY - " + proximaTitulo : "Sin más rojas semana";
   return false;
  }

bool HayFOMCProximo(datetime nyTime, datetime &fomcTimeOut, string &fomcTitleOut)
  {
   MqlDateTime dNow;
   TimeToStruct(nyTime, dNow);

   for(int i = 0; i < ArraySize(g_NewsList); i++)
     {
      if(!g_NewsList[i].isFOMC) continue;
      MqlDateTime dEv;
      TimeToStruct(g_NewsList[i].timeNY, dEv);
      if(dEv.year == dNow.year && dEv.mon == dNow.mon && dEv.day == dNow.day)
        {
         if(nyTime >= g_NewsList[i].timeNY - InpFOMCExitMinsBefore * 60 &&
            nyTime <= g_NewsList[i].timeNY + InpNewsMinsAfter * 60)
           {
            fomcTimeOut  = g_NewsList[i].timeNY;
            fomcTitleOut = g_NewsList[i].title;
            return true;
           }
        }
     }
   return false;
  }

string ExtractTag(string block, string tag)
  {
   string o = "<" + tag + ">", c = "</" + tag + ">";
   int p1 = StringFind(block, o); if(p1 < 0) return "";
   p1 += StringLen(o);
   int p2 = StringFind(block, c, p1); if(p2 < 0) return "";
   string val = StringSubstr(block, p1, p2 - p1);
   StringReplace(val, "<![CDATA[", ""); StringReplace(val, "]]>", "");
   StringTrimLeft(val); StringTrimRight(val);
   return val;
  }

datetime ParseFFDateTime(string dateStr, string timeStr)
  {
   StringToLower(timeStr);
   bool isPM = (StringFind(timeStr, "pm") >= 0), isAM = (StringFind(timeStr, "am") >= 0);
   if(!isPM && !isAM) return 0;
   StringReplace(timeStr, "am", ""); StringReplace(timeStr, "pm", "");
   string d[], t[];
   if(StringSplit(dateStr, '-', d) != 3 || StringSplit(timeStr, ':', t) != 2) return 0;
   int hour = (int)StringToInteger(t[0]);
   if(isPM && hour < 12) hour += 12;
   if(isAM && hour == 12) hour = 0;
   MqlDateTime dt;
   ZeroMemory(dt);
   dt.year = (int)StringToInteger(d[2]);
   dt.mon  = (int)StringToInteger(d[0]);
   dt.day  = (int)StringToInteger(d[1]);
   dt.hour = hour;
   dt.min  = (int)StringToInteger(t[1]);
   return StructToTime(dt);
  }

bool CalcularRango(datetime startSrv, datetime endSrv, bool requiereRangoCompleto)
  {
   double highs[], lows[];
   int ch = CopyHigh(_Symbol, PERIOD_M5, startSrv, endSrv, highs);
   int cl = CopyLow(_Symbol, PERIOD_M5, startSrv, endSrv, lows);
   if(ch <= 0 || cl <= 0) return false;
   if(requiereRangoCompleto && MathMin(ch, cl) < 6) return false;

   int idxMax = ArrayMaximum(highs), idxMin = ArrayMinimum(lows);
   if(idxMax >= 0 && idxMin >= 0 && highs[idxMax] > lows[idxMin])
     {
      g_RangeHigh = highs[idxMax];
      g_RangeLow  = lows[idxMin];
      g_RangeMid  = (g_RangeHigh + g_RangeLow) / 2.0;
      g_RangePct  = ((g_RangeHigh - g_RangeLow) / g_RangeLow) * 100.0;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| 11. INTERFAZ VISUAL Y PANEL HUD OPTIMIZADO                       |
//+------------------------------------------------------------------+
void DibujarEscenario(string tag, datetime tStart, datetime tEnd, datetime tSessStart, datetime tOpen, datetime tSessEnd)
  {
   string boxName = "NOVA_BOX_" + tag;
   if(ObjectFind(0, boxName) < 0) ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, tStart, g_RangeHigh, tEnd, g_RangeLow);
   else { ObjectMove(0, boxName, 0, tStart, g_RangeHigh); ObjectMove(0, boxName, 1, tEnd, g_RangeLow); }
   ObjectSetInteger(0, boxName, OBJPROP_COLOR, InpRangeColor);
   ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
   ObjectSetInteger(0, boxName, OBJPROP_BACK, true);

   DibujarLineaHorizontal("NOVA_HI_" + tag, tEnd, g_RangeHigh, tSessEnd, InpLinesColor, STYLE_SOLID);
   DibujarLineaHorizontal("NOVA_MD_" + tag, tEnd, g_RangeMid,  tSessEnd, clrGray,       STYLE_DOT);
   DibujarLineaHorizontal("NOVA_LO_" + tag, tEnd, g_RangeLow,  tSessEnd, InpLinesColor, STYLE_SOLID);

   DibujarMarcaVertical("NOVA_SESS_INI_" + tag, tSessStart, g_RangeHigh, g_RangeLow, clrDodgerBlue);
   DibujarMarcaVertical("NOVA_OPEN_930_" + tag, tOpen,      g_RangeHigh, g_RangeLow, clrGold);
   DibujarMarcaVertical("NOVA_SESS_FIN_" + tag, tSessEnd,   g_RangeHigh, g_RangeLow, clrTomato);
  }

void DibujarLineaHorizontal(string name, datetime t1, double price, datetime t2, color clr, ENUM_LINE_STYLE style)
  {
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
   else { ObjectMove(0, name, 0, t1, price); ObjectMove(0, name, 1, t2, price); }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr); ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
  }

void DibujarMarcaVertical(string name, datetime t, double high, double low, color clr)
  {
   double m = (high - low) * 0.25;
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_TREND, 0, t, high + m, t, low - m);
   else { ObjectMove(0, name, 0, t, high + m); ObjectMove(0, name, 1, t, low - m); }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr); ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
  }

void DibujarNivelEstructura(string baseName, datetime t1, double price, string label, color clr, bool esSuperior)
  {
   TraceEv("LEVEL", label, 0, price, 0, 0, 0,
           "t=" + TimeToString(t1, TIME_DATE|TIME_MINUTES) + " " + baseName);

   datetime t2 = t1 + PeriodSeconds(PERIOD_M5) * 3;
   string lineName = baseName + "_LN";
   if(ObjectFind(0, lineName) < 0)
     {
      ObjectCreate(0, lineName, OBJ_TREND, 0, t1, price, t2, price);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
     }

   string txtName = baseName + "_TX";
   if(ObjectFind(0, txtName) < 0)
     {
      ObjectCreate(0, txtName, OBJ_TEXT, 0, t2, price);
      ObjectSetString(0, txtName, OBJPROP_TEXT, " " + label);
      ObjectSetString(0, txtName, OBJPROP_FONT, "Segoe UI");
      ObjectSetInteger(0, txtName, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, txtName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, txtName, OBJPROP_ANCHOR, esSuperior ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
     }
  }

string TruncarTexto(string s, int maxLen)
  {
   if(StringLen(s) <= maxLen) return s;
   return StringSubstr(s, 0, maxLen - 3) + "...";
  }

void ActualizarHUD(datetime nyTime, string estado, color clrEstado)
  {
   int x = 14, y = 24, w = 460, h = 214;
   string bg = "NOVA_HUD_BG";

   if(ObjectFind(0, bg) < 0)
     {
      ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, bg, OBJPROP_XSIZE, w);
      ObjectSetInteger(0, bg, OBJPROP_YSIZE, h);
      ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'22,26,33');
      ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg, OBJPROP_COLOR, C'65,75,92');
      ObjectSetInteger(0, bg, OBJPROP_BACK, false);
      ObjectSetInteger(0, bg, OBJPROP_ZORDER, 10);
     }

   double riesgoUSD = AccountInfoDouble(ACCOUNT_BALANCE) * (InpRiskPercent / 100.0);
   string rangoTxt  = (g_RangeHigh > 0.0) ?
                      DoubleToString(g_RangeHigh, _Digits) + " - " + DoubleToString(g_RangeLow, _Digits) + " (" + DoubleToString(g_RangePct, 2) + "%)" :
                      "Calculando...";

   SetHudLine(0, x + 12, y + 10,  "NOVA BOT v3.15  |  NAS100 M5  |  NY Offset +" + IntegerToString(g_NYOffsetSec / 3600) + "h", clrGold, 9, true);
   SetHudLine(1, x + 12, y + 32,  "NY: " + TimeToString(nyTime, TIME_DATE|TIME_MINUTES) + " | " + TruncarTexto(estado, 36), clrEstado, 8, false);
   SetHudLine(2, x + 12, y + 50,  "Rango 02-07:  " + rangoTxt, clrWhite, 8, false);
   SetHudLine(3, x + 12, y + 68,  "Riesgo / Op:  " + DoubleToString(InpRiskPercent, 2) + "% ($" + DoubleToString(riesgoUSD, 2) + ")", clrSilver, 8, false);

   SetHudLine(4, x + 12, y + 92,  "Setup 1:      " + FormatearEstadoQe(g_S1, InpEnableSetup1), ColorEstadoQe(g_S1.stage, InpEnableSetup1), 8, false);
   SetHudLine(5, x + 12, y + 110, "Setup 2 Nac:  " + FormatearEstadoS2N(), ColorEstadoS2N(), 8, false);
   SetHudLine(6, x + 12, y + 128, "Setup 2 Cont: " + FormatearEstadoQe(g_S2C, InpEnableSetup2Cont), ColorEstadoQe(g_S2C.stage, InpEnableSetup2Cont), 8, false);
   SetHudLine(7, x + 12, y + 146, "Setup 3 Stop: " + (g_SessionBlockedS3 ? "ACTIVADO (DÍA CERRADO)" : "OK (Operativa Habilitada)"), g_SessionBlockedS3 ? clrTomato : clrLimeGreen, 8, false);

   SetHudLine(8, x + 12, y + 170, "Bullfy News:  " + TruncarTexto(g_NewsStatus, 46), clrSilver, 8, false);
   SetHudLine(9, x + 12, y + 188, "Próx. Roja:   " + TruncarTexto(g_NextNewsInfo, 46), clrWhite, 8, false);
  }

void SetHudLine(int idx, int x, int y, string text, color clr, int fontSize, bool bold)
  {
   string name = "NOVA_HUD_L" + IntegerToString(idx);
   bool created = false;
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetString(0, name, OBJPROP_FONT, bold ? "Segoe UI Semibold" : "Consolas");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 11);
      created = true;
     }
   if(created || g_HudCacheText[idx] != text)
     {
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      g_HudCacheText[idx] = text;
     }
   if(created || g_HudCacheColor[idx] != clr)
     {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      g_HudCacheColor[idx] = clr;
     }
  }

string FormatearEstadoQe(const QeMachine &m, bool enabled)
  {
   if(!enabled) return "DESACTIVADO";
   string st = EnumToString(m.stage);
   StringReplace(st, "QE_", "");
   string dir = (m.dir == 1) ? " [COMPRA]" : ((m.dir == -1) ? " [VENTA]" : "");
   string sl  = (m.slType != "") ? " (" + m.slType + ")" : "";
   return st + dir + sl;
  }

color ColorEstadoQe(ENUM_QE_STAGE st, bool enabled)
  {
   if(!enabled) return clrDimGray;
   if(st == QE_IN_TRADE) return clrLimeGreen;
   if(st == QE_ORDER_ACTIVE || st == QE_READY_ORDER || st == QE_WAIT_2QE_PB || st == QE_WAIT_2QE_BRK) return clrGold;
   if(st == QE_FINISHED) return clrGray;
   return clrWhite;
  }

string FormatearEstadoS2N()
  {
   if(!InpEnableSetup2Nac) return "DESACTIVADO";
   string st = EnumToString(g_S2NStage);
   StringReplace(st, "S2N_", "");
   string dir = (g_S2NDir == 1) ? " [COMPRA]" : ((g_S2NDir == -1) ? " [VENTA]" : "");
   string sl  = (g_S2NSLType != "") ? " (" + g_S2NSLType + ")" : "";
   return st + dir + sl;
  }

color ColorEstadoS2N()
  {
   if(!InpEnableSetup2Nac) return clrDimGray;
   if(g_S2NStage == S2N_IN_TRADE) return clrLimeGreen;
   if(g_S2NStage == S2N_ORDER_ACTIVE || g_S2NStage == S2N_READY_ORDER || g_S2NStage == S2N_WAIT_BOS) return clrGold;
   if(g_S2NStage == S2N_FINISHED) return clrGray;
   return clrWhite;
  }
//+------------------------------------------------------------------+
