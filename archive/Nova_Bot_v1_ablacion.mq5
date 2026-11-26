//+------------------------------------------------------------------+
//|                                                  Nova_Bot_v1.mq5 |
//|                     Estrategia Nova - Edición Producción v3.11   |
//|   HUD Gráfico + Arquitectura Modular + Calibración Real TV       |
//|   v3.11: ablación de salidas + traza CSV de decisiones           |
//+------------------------------------------------------------------+
#property copyright "Estrategia Nova"
#property version   "3.11"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| 1. PARÁMETROS CONFIGURABLES (INPUTS)                             |
//+------------------------------------------------------------------+
input group "=== 1. HORARIOS Y GRÁFICO ==="
input int    InpServerOffsetFromNY   = 7;               // Diferencia horaria: Hora Broker menos Hora NY
input int    InpRangeStartHour       = 2;               // Hora inicio rango (NY)
input int    InpRangeStartMin        = 0;               // Minuto inicio rango (NY)
input int    InpRangeEndHour         = 7;               // Hora fin rango (NY)
input int    InpRangeEndMin          = 0;               // Minuto fin rango (NY)
input int    InpSessionStartHour     = 8;               // Inicio ventana operativa NY
input int    InpLastEntryHourNY      = 15;              // Hora límite para ABRIR nuevas entradas (15:00 NY)
input int    InpLastEntryMinNY       = 0;               // Minuto límite para ABRIR nuevas entradas (NY)
input int    InpSessionEndHour       = 15;              // Hora cierre de gestión NY
input int    InpSessionEndMin        = 45;              // Minuto cierre de gestión NY
input bool   InpEnableAsiaSession    = false;           // Habilitar ventana Asia (18:00 - 21:30 NY)
input color  InpRangeColor           = clrMediumPurple; // Color caja de rango
input color  InpLinesColor           = clrBlack;        // Color líneas superior e inferior (0% y 100%)

input group "=== 2. RIESGO Y FILTRO DE NOTICIAS (BULLFY) ==="
input double InpRiskPercent          = 0.50;            // Riesgo por operación (% Balance - Prop Firm: 0.50%)
input bool   InpUseNewsFilter        = true;            // Activar bloqueo por noticias rojas (Forex Factory)
input string InpNewsCurrency         = "USD";           // Divisa a filtrar (USD para NAS100)
input int    InpNewsMinsBefore       = 5;               // Minutos bloqueo ANTES noticia roja (Bullfy: 5)
input int    InpNewsMinsAfter        = 5;               // Minutos bloqueo DESPUÉS noticia roja (Bullfy: 5)

input group "=== 3. SETUPS Y REGLAS CALIBRADAS TV ==="
input bool   InpEnableSetup1         = true;            // Activar Setup 1 (Compras y Ventas)
input bool   InpEnableSetup2Nac      = true;            // Activar Setup 2 Nacimiento (Compras y Ventas)
input bool   InpEnableSetup2Cont     = true;            // Activar Setup 2 Continuación (Piramidación)
input int    InpPullbackCandles      = 1;               // Velas contrarias/pausa para fijar 1Qe y 2Qe (TV: 1)
input bool   InpDirect2QeEntry       = true;            // Colocar Buy/Sell Stop directo en 2Qe (TV: true)
input bool   InpS1_AllowDeepPullback = true;            // Permitir retroceso profundo antes de 1Qe en S1
input bool   InpUseOptimizedTrail    = false;           // false = Trailing estricto original Nova
input bool   InpFilter930Open        = true;            // Gestionar trades abiertos a las 09:29 NY
input bool   InpAvoid10AMHour        = false;           // [Opcional] Evitar nuevas entradas de 10:00 a 10:59 NY
input int    InpGracePeriodMins      = 60;              // Hora de gracia sin momentum (minutos)

input group "=== 4. UMBRALES TÉCNICOS SETUP 1 & 2 CONTINUACIÓN ==="
input double InpS1_1QR_Pct           = 0.20;            // Setup 1: Quiebre inicial 1QR (%)
input double InpS2C_2QR_Pct          = 0.15;            // Setup 2 Cont: Quiebre opuesto 2QR (%)
input double InpCont_SL_AgresPct     = 0.50;            // Distancia > X% para SL Agresivo
input double InpCont_SL_ModMinPct    = 0.30;            // Distancia >= X% para SL Moderado

input group "=== 5. UMBRALES TÉCNICOS SETUP 2 NACIMIENTO ==="
input double InpS2N_1QR_Pct          = 0.05;            // Setup 2 Nac: Quiebre/absorción mínima (%)
input double InpS2N_EntryLevelPct    = 75.0;            // Nivel de entrada dentro del rango (%)
input double InpS2N_SL_AgresPct      = 0.25;            // Distancia > X% para SL Agresivo (Inicio Rango)
input double InpS2N_SL_ModMinPct     = 0.15;            // Distancia >= X% para SL Moderado
input bool   InpS2N_AvoidOpen10AM    = true;            // Bloquear barridos 1QR S2 Nac entre 09:25 y 09:55 NY

input group "=== 6. SALIDAS: ABLACIÓN (true = comportamiento v3.10) ==="
input bool   InpExit_Grace           = false;           // Cerrar a los N min si RR < umbral (Desactivado para ablación)
input bool   InpExit_Open930         = false;           // Aplicar filtro 09:29 (cerrar / mover SL) (Desactivado para ablación)
input bool   InpExit_S2N_BE          = false;           // S2 Nac: BE tras superar el rango (+0.15R) (Desactivado para ablación)
input bool   InpExit_Trailing        = false;           // Trailing por R y estructura (Desactivado para ablación)
input bool   InpExit_EndOfDay        = false;           // Cierre 15:40 si RR <= 0.15 (Desactivado para ablación)
input double InpGraceRR              = 0.50;            // Umbral R de la regla de gracia
input double InpTP_R_S1              = 5.0;             // TP Setup 1 (múltiplo de R)
input double InpTP_R_S2C             = 5.0;             // TP Setup 2 Continuación (múltiplo de R)
input double InpTP_R_S2N             = 4.0;             // TP Setup 2 Nacimiento (múltiplo de R)

input group "=== 7. TRAZA DE DIAGNÓSTICO ==="
input bool   InpDebugTrace           = false;           // Escribir CSV de decisiones (Common\Files)
input string InpTraceTag             = "";              // Etiqueta del CSV (vacío = automática)
input bool   InpTraceBars            = true;            // Registrar cambio de estado por vela

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
  };

enum ENUM_QE_STAGE
  {
   QE_INACTIVE = 0,
   QE_WAIT_1QE_PB,
   QE_WAIT_1QE_BRK,
   QE_WAIT_2QE_PB,
   QE_WAIT_2QE_BRK,
   QE_ORDER_ACTIVE,
   QE_IN_TRADE,
   QE_FINISHED
  };

struct QeMachine
  {
   ENUM_QE_STAGE stage;
   int           dir;          // 1 = Compra, -1 = Venta
   double        extreme;
   double        lvl1Qe;
   double        lvl2Qe;
   int           pbCount;
   int           tradesToday;
   double        initRisk;
   string        slType;
   bool          open930Done;
  };

enum ENUM_S2N_STAGE
  {
   S2N_WAIT_1QR = 0,
   S2N_WAIT_BOUNCE,
   S2N_WAIT_CH_CONFIRM,
   S2N_ORDER_ACTIVE,
   S2N_IN_TRADE,
   S2N_FINISHED
  };

CTrade         trade;

//--- Rango Diario
double         g_RangeHigh        = 0.0;
double         g_RangeLow         = 0.0;
double         g_RangeMid         = 0.0;
double         g_RangePct         = 0.0;
bool           g_RangeReady       = false;

//--- Calendario de Noticias
NewsEvent      g_NewsList[];
datetime       g_LastNewsFetch    = 0;
string         g_NewsStatus       = "Iniciando...";
string         g_NextNewsInfo     = "Sin eventos próximos";

//--- Control de Jornada y Máquinas de Estado
int            g_ActiveDayKey     = -1;
datetime       g_LastBarTime      = 0;
bool           g_SessionBlockedS3 = false;
bool           g_HistorySynced    = false;

QeMachine      g_S1;
QeMachine      g_S2C;

ENUM_S2N_STAGE g_S2NStage         = S2N_WAIT_1QR;
int            g_S2NDir           = 0;
double         g_S2NExtreme       = 0.0;
double         g_S2NCHLevel       = 0.0;
bool           g_S2NCHEstablished = false;
double         g_S2NInitRisk      = 0.0;
string         g_S2NSLType        = "";
bool           g_S2NOpen930Done   = false;
bool           g_HadSideBreakout  = false;
int            g_FirstBreakDir    = 0;

//--- Traza de diagnóstico (v3.11)
int            g_TraceHandle      = INVALID_HANDLE;
int            g_TraceSeq         = 0;
string         g_TraceFile        = "";
string         g_LastStateSig     = "";
bool           g_RangeLogged      = false;
int            g_NYOffsetSec      = 0;
string         g_SLReason         = "";

//+------------------------------------------------------------------+
//| 3. TRAZA DE DIAGNÓSTICO (CSV en Terminal\Common\Files)           |
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
   g_TraceFile = "Nova_trace_" + tag + ".csv";

   g_TraceHandle = FileOpen(g_TraceFile, FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON, ';');
   if(g_TraceHandle == INVALID_HANDLE)
     {
      Print("NOVA: no se pudo crear la traza ", g_TraceFile, " (err ", GetLastError(), ")");
      return;
     }

   FileWrite(g_TraceHandle, "seq", "srv_time", "ny_time", "event", "setup", "dir",
             "p1", "p2", "p3", "p4", "note");
   Print("NOVA v3.11 traza activa -> Common\\Files\\", g_TraceFile);
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
          " || ord=" + IntegerToString(OrdersTotal()) + " pos=" + IntegerToString(PositionsTotal());
  }

//+------------------------------------------------------------------+
//| 4. CICLO DE VIDA DEL EXPERT ADVISOR                              |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(_Period != PERIOD_M5)
      Print("AVISO: La estrategia Nova está diseñada para temporalidad M5.");

   g_NYOffsetSec = InpServerOffsetFromNY * 3600;

   trade.SetDeviationInPoints(30);
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   Comment("");
   g_HistorySynced = false;

   TraceInit();

   Print("NOVA v3.11 | ", _Symbol, " ", EnumToString(_Period),
         " | offsetNY=", InpServerOffsetFromNY, "h | riesgo=", DoubleToString(InpRiskPercent, 2), "%",
         " | salidas[gracia=", InpExit_Grace, " open930=", InpExit_Open930,
         " s2nBE=", InpExit_S2N_BE, " trail=", InpExit_Trailing, " eod=", InpExit_EndOfDay, "]",
         " | TP_R=", DoubleToString(InpTP_R_S1, 2), "/", DoubleToString(InpTP_R_S2C, 2), "/", DoubleToString(InpTP_R_S2N, 2));

   if(InpUseNewsFilter)
      ActualizarCalendarioNoticias(true);

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   TraceClose();
   ObjectsDeleteAll(0, "NOVA_");
   Comment("");
  }

void OnTick()
  {
   datetime srvTime = TimeCurrent();
   datetime nyTime  = srvTime - g_NYOffsetSec;

   if(InpUseNewsFilter && !MQLInfoInteger(MQL_TESTER))
      ActualizarCalendarioNoticias(false);

   bool bloqueadoPorNoticia = EstaBloqueadoPorNoticias(nyTime);

   MqlDateTime dtNy;
   TimeToStruct(nyTime, dtNy);

   // Reinicio diario al cambiar de fecha en Nueva York
   int dayKey = dtNy.year * 10000 + dtNy.mon * 100 + dtNy.day;
   if(dayKey != g_ActiveDayKey)
     {
      g_ActiveDayKey  = dayKey;
      g_HistorySynced = false;
      ResetearEstadoDiario();
     }

   // Marcas horarias del día actual
   datetime nyRangeStart, nyRangeEnd, nySessStart, nyLastEntry, nySessEnd;
   datetime srvRangeStart, srvRangeEnd, srvSessStart, srvMarketOpen, srvSessEnd;
   ConstruirHorariosDia(dtNy, nyRangeStart, nyRangeEnd, nySessStart, nyLastEntry, nySessEnd,
                        srvRangeStart, srvRangeEnd, srvSessStart, srvMarketOpen, srvSessEnd);

   // Evaluación de fase de sesión y cálculo del rango
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
      CalcularRango(srvRangeStart, srvTime);
      g_RangeReady = false;
     }
   else
     {
      CalcularRango(srvRangeStart, srvRangeEnd - 1);
      g_RangeReady = (g_RangeHigh > 0 && g_RangeLow > 0);

      if(g_RangeReady && !g_HistorySynced)
        {
         g_HistorySynced = true;
         if(!MQLInfoInteger(MQL_TESTER) && nyTime > nySessStart)
            ReconstruirEstructuraHoy(srvSessStart, nyLastEntry, InpServerOffsetFromNY * 3600);
        }

      if(g_SessionBlockedS3)
        {
         estado = "BLOQUEADO POR SETUP 3";
         clrEstado = clrTomato;
        }
      else if(bloqueadoPorNoticia)
        {
         estado = "PAUSADO - NOTICIA ROJA";
         clrEstado = clrGold;
         CancelarTodasLasPendientes();
        }
      else if(nyTime < nySessStart)
        {
         estado = "RANGO LISTO - ESPERANDO 08:00 NY";
         clrEstado = clrDodgerBlue;
        }
      else if(nyTime >= nySessStart && nyTime <= nyLastEntry)
        {
         estado = "VENTANA ENTRADAS ACTIVA";
         clrEstado = clrLimeGreen;
        }
      else if(nyTime > nyLastEntry && nyTime <= nySessEnd)
        {
         estado = "SOLO GESTIÓN (SIN NUEVAS)";
         clrEstado = clrGold;
        }
      else
        {
         estado = "FUERA DE HORARIO OPERATIVO";
         clrEstado = clrGray;
        }
     }

   // Dibujo de cajas y niveles de sesión
   if(g_RangeHigh > 0 && g_RangeLow > 0)
     {
      string dayTag = IntegerToString(dtNy.year) + "_" + IntegerToString(dtNy.mon) + "_" + IntegerToString(dtNy.day);
      DibujarEscenario(dayTag, srvRangeStart, srvRangeEnd, srvSessStart, srvMarketOpen, srvSessEnd);
     }

   // Ejecución operativa
   if(g_RangeReady)
     {
      if(!g_RangeLogged)
        {
         g_RangeLogged = true;
         TraceEv("DAY", "RANGE", 0, g_RangeHigh, g_RangeLow, g_RangeMid, g_RangePct,
                 "S1_1QR=" + Fmt(g_RangeHigh * (1.0 + InpS1_1QR_Pct / 100.0)) + "/" +
                 Fmt(g_RangeLow  * (1.0 - InpS1_1QR_Pct / 100.0)) +
                 " S2N_1QR=" + Fmt(g_RangeLow * (1.0 - InpS2N_1QR_Pct / 100.0)) + "/" +
                 Fmt(g_RangeHigh * (1.0 + InpS2N_1QR_Pct / 100.0)));
        }

      GestionarMotorQe(g_S1, MAGIC_S1, nyTime, srvTime, false, nyLastEntry);
      GestionarMotorQe(g_S2C, MAGIC_S2_CONT, nyTime, srvTime, true, nyLastEntry);
      GestionarSetup2Nacimiento(nyTime, srvTime, nyLastEntry);

      datetime barTime = iTime(_Symbol, PERIOD_M5, 0);
      if(barTime != g_LastBarTime)
        {
         g_LastBarTime = barTime;
         bool puedeBuscar = EstaEnVentanaEntradas(nyTime, nySessStart, nyLastEntry) && !bloqueadoPorNoticia && !g_SessionBlockedS3;
         if(puedeBuscar)
            EvaluarVela(nyTime, 1, false);

         if(InpDebugTrace && InpTraceBars)
           {
            string sig = StateSignature();
            if(sig != g_LastStateSig)
              {
               g_LastStateSig = sig;
               TraceEv("BAR", "M5", 0,
                       iOpen(_Symbol, PERIOD_M5, 1), iHigh(_Symbol, PERIOD_M5, 1),
                       iLow(_Symbol, PERIOD_M5, 1),  iClose(_Symbol, PERIOD_M5, 1),
                       "bar=" + TimeToString(iTime(_Symbol, PERIOD_M5, 1), TIME_DATE|TIME_MINUTES) +
                       " busca=" + (puedeBuscar ? "1" : "0") +
                       " ny=" + TimeToString(nyTime, TIME_MINUTES) + " || " + sig);
              }
           }
        }
     }

   // Actualización del panel HUD (solo en vivo o modo visual)
   if(!MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE))
      ActualizarHUD(nyTime, estado, clrEstado);
  }

//+------------------------------------------------------------------+
//| 4. GESTIÓN DE HORARIOS Y REINICIO DE ESTADO                      |
//+------------------------------------------------------------------+
void ConstruirHorariosDia(const MqlDateTime &dtNy,
                          datetime &nyRangeStart, datetime &nyRangeEnd, datetime &nySessStart, datetime &nyLastEntry, datetime &nySessEnd,
                          datetime &srvRangeStart, datetime &srvRangeEnd, datetime &srvSessStart, datetime &srvMarketOpen, datetime &srvSessEnd)
  {
   MqlDateTime dtTemp = dtNy;
   dtTemp.sec = 0;

   dtTemp.hour = InpRangeStartHour; dtTemp.min = InpRangeStartMin;
   nyRangeStart = StructToTime(dtTemp);

   dtTemp.hour = InpRangeEndHour;   dtTemp.min = InpRangeEndMin;
   nyRangeEnd   = StructToTime(dtTemp);

   dtTemp.hour = InpSessionStartHour; dtTemp.min = 0;
   nySessStart  = StructToTime(dtTemp);

   dtTemp.hour = InpLastEntryHourNY;  dtTemp.min = InpLastEntryMinNY;
   nyLastEntry  = StructToTime(dtTemp);

   dtTemp.hour = 9; dtTemp.min = 30;
   datetime nyMarketOpen = StructToTime(dtTemp);

   dtTemp.hour = InpSessionEndHour; dtTemp.min = InpSessionEndMin;
   nySessEnd    = StructToTime(dtTemp);

   int offsetSec = InpServerOffsetFromNY * 3600;
   srvRangeStart = nyRangeStart + offsetSec;
   srvRangeEnd   = nyRangeEnd   + offsetSec;
   srvSessStart  = nySessStart  + offsetSec;
   srvMarketOpen = nyMarketOpen + offsetSec;
   srvSessEnd    = nySessEnd    + offsetSec;
  }

bool EstaEnVentanaEntradas(datetime nyTime, datetime nySessStart, datetime nyLastEntry)
  {
   if(nyTime >= nySessStart && nyTime <= nyLastEntry) return true;
   if(InpEnableAsiaSession)
     {
      MqlDateTime dt; TimeToStruct(nyTime, dt);
      int mins = dt.hour * 60 + dt.min;
      if(mins >= (18 * 60) && mins <= (21 * 60 + 30)) return true;
     }
   return false;
  }

void ResetearQeMachine(QeMachine &m)
  {
   m.stage       = QE_INACTIVE;
   m.dir         = 0;
   m.extreme     = 0.0;
   m.lvl1Qe      = 0.0;
   m.lvl2Qe      = 0.0;
   m.pbCount     = 0;
   m.tradesToday = 0;
   m.initRisk    = 0.0;
   m.slType      = "";
   m.open930Done = false;
  }

void ResetearEstadoDiario()
  {
   g_RangeHigh        = 0.0;
   g_RangeLow         = 0.0;
   g_RangeMid         = 0.0;
   g_RangePct         = 0.0;
   g_RangeReady       = false;
   g_RangeLogged      = false;
   g_SessionBlockedS3 = false;

   ResetearQeMachine(g_S1);
   ResetearQeMachine(g_S2C);

   g_S2NStage         = S2N_WAIT_1QR;
   g_S2NDir           = 0;
   g_S2NExtreme       = 0.0;
   g_S2NCHLevel       = 0.0;
   g_S2NCHEstablished = false;
   g_S2NInitRisk      = 0.0;
   g_S2NSLType        = "";
   g_S2NOpen930Done   = false;
   g_HadSideBreakout  = false;
   g_FirstBreakDir    = 0;
  }

void ReconstruirEstructuraHoy(datetime srvSessStart, datetime nyLastEntry, int offsetSec)
  {
   int startShift = iBarShift(_Symbol, PERIOD_M5, srvSessStart, false);
   if(startShift < 1) return;

   for(int s = startShift; s >= 1; s--)
     {
      datetime barSrv = iTime(_Symbol, PERIOD_M5, s);
      datetime barNY  = barSrv - offsetSec;
      if(barNY <= nyLastEntry)
         EvaluarVela(barNY, s, true);
     }

   if(g_S1.stage == QE_ORDER_ACTIVE && !TieneOrdenOPosicion(MAGIC_S1))
      g_S1.stage = QE_WAIT_2QE_BRK;
   if(g_S2C.stage == QE_ORDER_ACTIVE && !TieneOrdenOPosicion(MAGIC_S2_CONT))
      g_S2C.stage = QE_WAIT_2QE_BRK;
   if(g_S2NStage == S2N_ORDER_ACTIVE && !TieneOrdenOPosicion(MAGIC_S2_NAC))
      g_S2NStage = S2N_WAIT_CH_CONFIRM;
  }

bool TieneOrdenOPosicion(ulong magic)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(OrderGetTicket(i)) && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == magic)
         return true;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol && (ulong)PositionGetInteger(POSITION_MAGIC) == magic)
         return true;
   return false;
  }

//+------------------------------------------------------------------+
//| 5. MOTOR ESTRUCTURAL EN VELA M5 (SETUPS 1, 2 NAC Y 2 CONT)       |
//+------------------------------------------------------------------+
void EvaluarVela(datetime nyTime, int shift, bool soloReconstruccion)
  {
   MqlDateTime dt; TimeToStruct(nyTime, dt);
   int minsNY = dt.hour * 60 + dt.min;

   if(InpAvoid10AMHour && minsNY >= (10 * 60) && minsNY < (11 * 60))
      return;

   bool enLatigazo930        = (InpFilter930Open && minsNY >= (9 * 60 + 25) && minsNY < (9 * 60 + 35));
   bool bloqueadoAperturaS2N = (InpS2N_AvoidOpen10AM && minsNY >= (9 * 60 + 25) && minsNY < (9 * 60 + 55));

   double open1   = iOpen(_Symbol, PERIOD_M5, shift);
   double high1   = iHigh(_Symbol, PERIOD_M5, shift);
   double low1    = iLow(_Symbol, PERIOD_M5, shift);
   double close1  = iClose(_Symbol, PERIOD_M5, shift);
   datetime time1 = iTime(_Symbol, PERIOD_M5, shift);

   double s1Buy1QR   = g_RangeHigh * (1.0 + InpS1_1QR_Pct / 100.0);
   double s1Sell1QR  = g_RangeLow  * (1.0 - InpS1_1QR_Pct / 100.0);
   double s2nBuy1QR  = g_RangeLow  * (1.0 - InpS2N_1QR_Pct / 100.0);
   double s2nSell1QR = g_RangeHigh * (1.0 + InpS2N_1QR_Pct / 100.0);

   //--- A. Setup 1: Activación inicial (1QR >= 0.20% con cuerpo)
   if(InpEnableSetup1 && !enLatigazo930 && g_S1.stage == QE_INACTIVE && g_S1.tradesToday == 0)
     {
      if(close1 >= s1Buy1QR && close1 > open1)
        {
         g_S1.dir = 1; g_S1.extreme = high1; g_S1.pbCount = 0; g_S1.stage = QE_WAIT_1QE_PB;
         if(!g_HadSideBreakout) { g_HadSideBreakout = true; g_FirstBreakDir = 1; }
         DibujarNivelEstructura("NOVA_S1_1QR_" + TimeToString(time1), time1, high1, "S1 1QR", clrDodgerBlue, true);
        }
      else if(close1 <= s1Sell1QR && close1 < open1)
        {
         g_S1.dir = -1; g_S1.extreme = low1; g_S1.pbCount = 0; g_S1.stage = QE_WAIT_1QE_PB;
         if(!g_HadSideBreakout) { g_HadSideBreakout = true; g_FirstBreakDir = -1; }
         DibujarNivelEstructura("NOVA_S1_1QR_" + TimeToString(time1), time1, low1, "S1 1QR", clrCrimson, false);
        }
     }

   //--- B. Setup 2 Nacimiento: Barrido de liquidez (1QR >= 0.05%)
   if(InpEnableSetup2Nac && !bloqueadoAperturaS2N && g_S2NStage == S2N_WAIT_1QR)
     {
      if(low1 <= s2nBuy1QR)
        {
         g_S2NDir = 1; g_S2NExtreme = low1; g_S2NCHLevel = high1;
         g_S2NCHEstablished = false; g_S2NStage = S2N_WAIT_BOUNCE;
         if(!g_HadSideBreakout) { g_HadSideBreakout = true; g_FirstBreakDir = -1; }
         DibujarNivelEstructura("NOVA_S2N_1QR_" + TimeToString(time1), time1, low1, "S2 1QR", clrDarkOrange, false);
        }
      else if(high1 >= s2nSell1QR)
        {
         g_S2NDir = -1; g_S2NExtreme = high1; g_S2NCHLevel = low1;
         g_S2NCHEstablished = false; g_S2NStage = S2N_WAIT_BOUNCE;
         if(!g_HadSideBreakout) { g_HadSideBreakout = true; g_FirstBreakDir = 1; }
         DibujarNivelEstructura("NOVA_S2N_1QR_" + TimeToString(time1), time1, high1, "S2 1QR", clrDarkOrange, true);
        }
     }

   //--- C. Progresión Setup 2 Nacimiento
   if(InpEnableSetup2Nac && g_S2NStage != S2N_WAIT_1QR && g_S2NStage != S2N_FINISHED)
      ProcesarSetup2NacimientoVela(open1, high1, low1, close1, time1, soloReconstruccion);

   //--- D. Setup 2 Continuación: Quiebre opuesto >= 0.15% con cuerpo
   if(InpEnableSetup2Cont && !enLatigazo930 && g_HadSideBreakout && g_S2C.stage == QE_INACTIVE && g_S2C.tradesToday == 0)
     {
      double s2cBuy2QR  = g_RangeHigh * (1.0 + InpS2C_2QR_Pct / 100.0);
      double s2cSell2QR = g_RangeLow  * (1.0 - InpS2C_2QR_Pct / 100.0);

      if(g_FirstBreakDir == -1 && close1 >= s2cBuy2QR && close1 > open1)
        {
         g_S2C.dir = 1; g_S2C.extreme = high1; g_S2C.pbCount = 0; g_S2C.stage = QE_WAIT_1QE_PB;
         DibujarNivelEstructura("NOVA_S2C_2QR_" + TimeToString(time1), time1, high1, "S2C 2QR", clrTeal, true);
        }
      else if(g_FirstBreakDir == 1 && close1 <= s2cSell2QR && close1 < open1)
        {
         g_S2C.dir = -1; g_S2C.extreme = low1; g_S2C.pbCount = 0; g_S2C.stage = QE_WAIT_1QE_PB;
         DibujarNivelEstructura("NOVA_S2C_2QR_" + TimeToString(time1), time1, low1, "S2C 2QR", clrMaroon, false);
        }
     }

   //--- E. Progresión Motor Qe (Setup 1 y Setup 2 Continuación)
   if(InpEnableSetup1 && g_S1.stage != QE_INACTIVE && g_S1.stage != QE_FINISHED)
      ProcesarMotorQeVela(g_S1, MAGIC_S1, false, open1, high1, low1, close1, time1, soloReconstruccion);

   if(InpEnableSetup2Cont && g_S2C.stage != QE_INACTIVE && g_S2C.stage != QE_FINISHED)
      ProcesarMotorQeVela(g_S2C, MAGIC_S2_CONT, true, open1, high1, low1, close1, time1, soloReconstruccion);
  }

void ProcesarSetup2NacimientoVela(double open1, double high1, double low1, double close1, datetime time1, bool soloReconstruccion)
  {
   if(g_S2NStage == S2N_ORDER_ACTIVE || g_S2NStage == S2N_IN_TRADE) return;

   if(g_S2NDir == 1)
     {
      if(low1 < g_S2NExtreme)
        {
         g_S2NExtreme = low1;
         if(!g_S2NCHEstablished) g_S2NCHLevel = high1;
         return;
        }
      if(g_S2NStage == S2N_WAIT_BOUNCE)
        {
         if(!g_S2NCHEstablished && high1 > g_S2NCHLevel) g_S2NCHLevel = high1;
         if(close1 < open1) { g_S2NCHEstablished = true; g_S2NStage = S2N_WAIT_CH_CONFIRM; }
         else if(close1 > g_RangeMid && close1 > open1) { g_S2NStage = S2N_WAIT_CH_CONFIRM; ConfirmarYColocarS2Nac(time1, soloReconstruccion); }
        }
      else if(g_S2NStage == S2N_WAIT_CH_CONFIRM)
        {
         if(close1 > g_S2NCHLevel && close1 > open1 && close1 > g_RangeLow)
            ConfirmarYColocarS2Nac(time1, soloReconstruccion);
        }
     }
   else if(g_S2NDir == -1)
     {
      if(high1 > g_S2NExtreme)
        {
         g_S2NExtreme = high1;
         if(!g_S2NCHEstablished) g_S2NCHLevel = low1;
         return;
        }
      if(g_S2NStage == S2N_WAIT_BOUNCE)
        {
         if(!g_S2NCHEstablished && low1 < g_S2NCHLevel) g_S2NCHLevel = low1;
         if(close1 > open1) { g_S2NCHEstablished = true; g_S2NStage = S2N_WAIT_CH_CONFIRM; }
         else if(close1 < g_RangeMid && close1 < open1) { g_S2NStage = S2N_WAIT_CH_CONFIRM; ConfirmarYColocarS2Nac(time1, soloReconstruccion); }
        }
      else if(g_S2NStage == S2N_WAIT_CH_CONFIRM)
        {
         if(close1 < g_S2NCHLevel && close1 < open1 && close1 < g_RangeHigh)
            ConfirmarYColocarS2Nac(time1, soloReconstruccion);
        }
     }
  }

void ConfirmarYColocarS2Nac(datetime time1, bool soloReconstruccion)
  {
   double rangeSize = g_RangeHigh - g_RangeLow;
   double frac      = InpS2N_EntryLevelPct / 100.0;
   double entry75   = 0.0;
   double slPrice   = 0.0;
   double distPct   = 0.0;
   double minStop   = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   ENUM_ORDER_TYPE oType;

   if(g_S2NDir == 1)
     {
      oType   = ORDER_TYPE_BUY_STOP;
      entry75 = NormalizeDouble(g_RangeLow + rangeSize * frac, _Digits);
      if(!soloReconstruccion && SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= entry75 - minStop)
        {
         TraceEv("SKIP", "S2N", g_S2NDir, entry75, 0, 0, 0,
                 "precio ya supero el 75% (ask=" + Fmt(SymbolInfoDouble(_Symbol, SYMBOL_ASK)) + ")");
         g_S2NStage = S2N_FINISHED;
         return;
        }

      distPct = ((g_RangeLow - g_S2NExtreme) / g_RangeLow) * 100.0;
      if(distPct > InpS2N_SL_AgresPct)       { slPrice = g_RangeLow; g_S2NSLType = "SL A"; }
      else if(distPct >= InpS2N_SL_ModMinPct){ slPrice = (g_RangeLow + g_S2NExtreme) / 2.0; g_S2NSLType = "SL M"; }
      else                                   { slPrice = g_S2NExtreme - _Point * 10; g_S2NSLType = "SL C"; }
     }
   else
     {
      oType   = ORDER_TYPE_SELL_STOP;
      entry75 = NormalizeDouble(g_RangeHigh - rangeSize * frac, _Digits);
      if(!soloReconstruccion && SymbolInfoDouble(_Symbol, SYMBOL_BID) <= entry75 + minStop)
        {
         TraceEv("SKIP", "S2N", g_S2NDir, entry75, 0, 0, 0,
                 "precio ya supero el 75% (bid=" + Fmt(SymbolInfoDouble(_Symbol, SYMBOL_BID)) + ")");
         g_S2NStage = S2N_FINISHED;
         return;
        }

      distPct = ((g_S2NExtreme - g_RangeHigh) / g_RangeHigh) * 100.0;
      if(distPct > InpS2N_SL_AgresPct)       { slPrice = g_RangeHigh; g_S2NSLType = "SL A"; }
      else if(distPct >= InpS2N_SL_ModMinPct){ slPrice = (g_RangeHigh + g_S2NExtreme) / 2.0; g_S2NSLType = "SL M"; }
      else                                   { slPrice = g_S2NExtreme + _Point * 10; g_S2NSLType = "SL C"; }
     }

   slPrice = NormalizeDouble(slPrice, _Digits);
   double distSL = MathAbs(entry75 - slPrice);
   if(distSL <= 0) return;

   g_S2NInitRisk = distSL;
   DibujarNivelEstructura("NOVA_S2N_CH_" + TimeToString(time1), time1, entry75, "S2 NAC 75%", clrDarkOrange, (g_S2NDir == 1));

   if(soloReconstruccion) { g_S2NStage = S2N_ORDER_ACTIVE; return; }

   double lotes = CalcularLotajePorRiesgo(distSL, entry75, slPrice, oType);
   double tpPrice = (oType == ORDER_TYPE_BUY_STOP) ?
                    NormalizeDouble(entry75 + distSL * InpTP_R_S2N, _Digits) :
                    NormalizeDouble(entry75 - distSL * InpTP_R_S2N, _Digits);

   trade.SetExpertMagicNumber(MAGIC_S2_NAC);
   string comment = (oType == ORDER_TYPE_BUY_STOP) ? "NOVA_S2_NAC_BUY" : "NOVA_S2_NAC_SELL";
   if(trade.OrderOpen(_Symbol, oType, lotes, 0.0, entry75, slPrice, tpPrice, ORDER_TIME_DAY, 0, comment))
     {
      g_S2NStage = S2N_ORDER_ACTIVE;
      TraceEv("ORDER", "S2N", g_S2NDir, entry75, slPrice, tpPrice, lotes,
              "R=" + Fmt(distSL) + " " + g_S2NSLType + " tpR=" + DoubleToString(InpTP_R_S2N, 2));
     }
   else
      TraceEv("REJECT", "S2N", g_S2NDir, entry75, slPrice, tpPrice, lotes,
              "ret=" + IntegerToString(trade.ResultRetcode()) + " " + trade.ResultRetcodeDescription());
  }

void ProcesarMotorQeVela(QeMachine &m, ulong magic, bool esContinuacion, double open1, double high1, double low1, double close1, datetime time1, bool soloReconstruccion)
  {
   if(m.stage == QE_ORDER_ACTIVE || m.stage == QE_IN_TRADE || m.stage == QE_FINISHED) return;
   string prefix = esContinuacion ? "S2C" : "S1";
   int reqPB = MathMax(1, InpPullbackCandles);

   if(m.dir == 1)
     {
      if(!InpS1_AllowDeepPullback && close1 < g_RangeLow) { m.stage = QE_FINISHED; return; }

      if(m.stage == QE_WAIT_1QE_PB)
        {
         if(high1 > m.extreme) { m.extreme = high1; m.pbCount = 0; }
         else if(++m.pbCount >= reqPB)
           {
            m.lvl1Qe = m.extreme; m.stage = QE_WAIT_1QE_BRK;
            DibujarNivelEstructura("NOVA_" + prefix + "_1QE_" + TimeToString(time1), time1, m.lvl1Qe, prefix + " 1Qe", clrDodgerBlue, true);
           }
        }
      else if(m.stage == QE_WAIT_1QE_BRK)
        {
         if(close1 > m.lvl1Qe && close1 > open1) { m.extreme = high1; m.pbCount = 0; m.stage = QE_WAIT_2QE_PB; }
        }
      else if(m.stage == QE_WAIT_2QE_PB)
        {
         if(high1 > m.extreme) { m.extreme = high1; m.pbCount = 0; }
         else if(++m.pbCount >= reqPB)
           {
            m.lvl2Qe = m.extreme;
            DibujarNivelEstructura("NOVA_" + prefix + "_2QE_" + TimeToString(time1), time1, m.lvl2Qe, prefix + " 2Qe (PE)", clrForestGreen, true);
            if(InpDirect2QeEntry)
               ColocarOrdenMotorQe(m, magic, esContinuacion, ORDER_TYPE_BUY_STOP, NormalizeDouble(m.lvl2Qe + _Point * 10, _Digits), soloReconstruccion);
            else
               m.stage = QE_WAIT_2QE_BRK;
           }
        }
      else if(m.stage == QE_WAIT_2QE_BRK)
        {
         if(close1 > m.lvl2Qe && close1 > open1)
           {
            double entryPrice = NormalizeDouble(high1 + _Point * 10, _Digits);
            DibujarNivelEstructura("NOVA_" + prefix + "_2QE_" + TimeToString(time1), time1, entryPrice, prefix + " PE", clrForestGreen, true);
            ColocarOrdenMotorQe(m, magic, esContinuacion, ORDER_TYPE_BUY_STOP, entryPrice, soloReconstruccion);
           }
        }
     }
   else if(m.dir == -1)
     {
      if(!InpS1_AllowDeepPullback && close1 > g_RangeHigh) { m.stage = QE_FINISHED; return; }

      if(m.stage == QE_WAIT_1QE_PB)
        {
         if(low1 < m.extreme) { m.extreme = low1; m.pbCount = 0; }
         else if(++m.pbCount >= reqPB)
           {
            m.lvl1Qe = m.extreme; m.stage = QE_WAIT_1QE_BRK;
            DibujarNivelEstructura("NOVA_" + prefix + "_1QE_" + TimeToString(time1), time1, m.lvl1Qe, prefix + " 1Qe", clrCrimson, false);
           }
        }
      else if(m.stage == QE_WAIT_1QE_BRK)
        {
         if(close1 < m.lvl1Qe && close1 < open1) { m.extreme = low1; m.pbCount = 0; m.stage = QE_WAIT_2QE_PB; }
        }
      else if(m.stage == QE_WAIT_2QE_PB)
        {
         if(low1 < m.extreme) { m.extreme = low1; m.pbCount = 0; }
         else if(++m.pbCount >= reqPB)
           {
            m.lvl2Qe = m.extreme;
            DibujarNivelEstructura("NOVA_" + prefix + "_2QE_" + TimeToString(time1), time1, m.lvl2Qe, prefix + " 2Qe (PE)", clrFireBrick, false);
            if(InpDirect2QeEntry)
               ColocarOrdenMotorQe(m, magic, esContinuacion, ORDER_TYPE_SELL_STOP, NormalizeDouble(m.lvl2Qe - _Point * 10, _Digits), soloReconstruccion);
            else
               m.stage = QE_WAIT_2QE_BRK;
           }
        }
      else if(m.stage == QE_WAIT_2QE_BRK)
        {
         if(close1 < m.lvl2Qe && close1 < open1)
           {
            double entryPrice = NormalizeDouble(low1 - _Point * 10, _Digits);
            DibujarNivelEstructura("NOVA_" + prefix + "_2QE_" + TimeToString(time1), time1, entryPrice, prefix + " PE", clrFireBrick, false);
            ColocarOrdenMotorQe(m, magic, esContinuacion, ORDER_TYPE_SELL_STOP, entryPrice, soloReconstruccion);
           }
        }
     }
  }

void ColocarOrdenMotorQe(QeMachine &m, ulong magic, bool esContinuacion, ENUM_ORDER_TYPE orderType, double entryPrice, bool soloReconstruccion)
  {
   double slPrice = 0.0;
   double distPct = 0.0;
   double minStop = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;

   if(orderType == ORDER_TYPE_BUY_STOP)
     {
      if(!soloReconstruccion && SymbolInfoDouble(_Symbol, SYMBOL_ASK) >= entryPrice - minStop)
        {
         TraceEv("SKIP", esContinuacion ? "S2C" : "S1", m.dir, entryPrice, 0, 0, 0,
                 "ask ya supero la entrada (ask=" + Fmt(SymbolInfoDouble(_Symbol, SYMBOL_ASK)) + ")");
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
      if(!soloReconstruccion && SymbolInfoDouble(_Symbol, SYMBOL_BID) <= entryPrice + minStop)
        {
         TraceEv("SKIP", esContinuacion ? "S2C" : "S1", m.dir, entryPrice, 0, 0, 0,
                 "bid ya supero la entrada (bid=" + Fmt(SymbolInfoDouble(_Symbol, SYMBOL_BID)) + ")");
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
   if(distSL <= 0) return;

   m.initRisk = distSL;
   if(soloReconstruccion) { m.stage = QE_ORDER_ACTIVE; return; }

   double lotes = CalcularLotajePorRiesgo(distSL, entryPrice, slPrice, orderType);
   double tpR    = esContinuacion ? InpTP_R_S2C : InpTP_R_S1;
   double tpPrice = (orderType == ORDER_TYPE_BUY_STOP) ?
                    NormalizeDouble(entryPrice + distSL * tpR, _Digits) :
                    NormalizeDouble(entryPrice - distSL * tpR, _Digits);

   trade.SetExpertMagicNumber(magic);
   string comment = esContinuacion ?
                    ((orderType == ORDER_TYPE_BUY_STOP) ? "NOVA_S2_CONT_BUY" : "NOVA_S2_CONT_SELL") :
                    ((orderType == ORDER_TYPE_BUY_STOP) ? "NOVA_S1_BUY" : "NOVA_S1_SELL");

   if(trade.OrderOpen(_Symbol, orderType, lotes, 0.0, entryPrice, slPrice, tpPrice, ORDER_TIME_DAY, 0, comment))
     {
      m.stage = QE_ORDER_ACTIVE;
      TraceEv("ORDER", esContinuacion ? "S2C" : "S1", m.dir, entryPrice, slPrice, tpPrice, lotes,
              "R=" + Fmt(distSL) + " " + m.slType + " tpR=" + DoubleToString(tpR, 2));
     }
   else
      TraceEv("REJECT", esContinuacion ? "S2C" : "S1", m.dir, entryPrice, slPrice, tpPrice, lotes,
              "ret=" + IntegerToString(trade.ResultRetcode()) + " " + trade.ResultRetcodeDescription());
  }

//+------------------------------------------------------------------+
//| 6. GESTIÓN ACTIVA DE POSICIONES (TRAILING, GRACIA, 9:30, 15:40)  |
//+------------------------------------------------------------------+
void GestionarMotorQe(QeMachine &m, ulong magic, datetime nyTime, datetime srvTime, bool esContinuacion, datetime nyLastEntry)
  {
   MqlDateTime dt; TimeToStruct(nyTime, dt);
   int minsNY = dt.hour * 60 + dt.min;
   trade.SetExpertMagicNumber(magic);

   bool tienePendiente = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && (ulong)OrderGetInteger(ORDER_MAGIC) == magic)
        {
         tienePendiente = true;
         if(nyTime > nyLastEntry)
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
         tienePosicion = true;
         bool esNuevaPos = (m.stage != QE_IN_TRADE);
         if(esNuevaPos) { m.stage = QE_IN_TRADE; m.tradesToday++; }

         long     posType   = PositionGetInteger(POSITION_TYPE);
         double   openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double   curSL     = PositionGetDouble(POSITION_SL);
         double   curTP     = PositionGetDouble(POSITION_TP);
         datetime openTime  = (datetime)PositionGetInteger(POSITION_TIME);

         double curPrice  = (posType == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double diffPrice = (posType == POSITION_TYPE_BUY) ? (curPrice - openPrice) : (openPrice - curPrice);
         double currentRR = (m.initRisk > 0) ? (diffPrice / m.initRisk) : 0.0;
         string setupName = esContinuacion ? "S2C" : "S1";
         int    dirPos    = (posType == POSITION_TYPE_BUY) ? 1 : -1;

         if(esNuevaPos)
            TraceEv("FILL", setupName, dirPos, openPrice, curSL, curTP, m.initRisk,
                    "ticket=" + IntegerToString((long)ticket));

         if(InpExit_EndOfDay && minsNY >= (15 * 60 + 40) && currentRR <= 0.15)
           {
            trade.PositionClose(ticket);
            TraceEv("EXIT", setupName, dirPos, curPrice, openPrice, currentRR, 0.0,
                    "EOD_1540 ticket=" + IntegerToString((long)ticket));
            m.stage = QE_FINISHED;
            continue;
           }

         if(InpExit_Open930 && InpFilter930Open && minsNY == (9 * 60 + 29) && !m.open930Done)
           {
            m.open930Done = true;
            if(currentRR >= -0.10 && currentRR <= 0.15)
              {
               trade.PositionClose(ticket);
               TraceEv("EXIT", setupName, dirPos, curPrice, openPrice, currentRR, 0.0,
                       "OPEN930_FLAT ticket=" + IntegerToString((long)ticket));
               m.stage = (nyTime <= nyLastEntry) ? QE_WAIT_2QE_BRK : QE_FINISHED;
               continue;
              }
            else if(currentRR > 0.15)
              {
               double sl930 = (posType == POSITION_TYPE_BUY) ? openPrice - (m.initRisk * 0.25) : openPrice + (m.initRisk * 0.25);
               MoverSLSeguro(ticket, posType, curSL, sl930, curTP, "OPEN930");
              }
           }

         int minsAbierto = (int)((srvTime - openTime) / 60);
         if(InpExit_Grace && minsAbierto >= InpGracePeriodMins && currentRR < InpGraceRR)
           {
            trade.PositionClose(ticket);
            TraceEv("EXIT", setupName, dirPos, curPrice, openPrice, currentRR, (double)minsAbierto,
                    "GRACE ticket=" + IntegerToString((long)ticket));
            m.stage = (m.tradesToday < 2 && nyTime <= nyLastEntry) ? QE_WAIT_2QE_BRK : QE_FINISHED;
            continue;
           }

         AplicarTrailingMotorQe(ticket, posType, openPrice, curSL, curTP, currentRR, m.initRisk);
        }
     }

   if(!tienePosicion && !tienePendiente && (m.stage == QE_IN_TRADE || m.stage == QE_ORDER_ACTIVE))
     {
      if(esContinuacion && m.stage == QE_IN_TRADE && UltimoTradeCerroEnPerdida(magic))
        {
         g_SessionBlockedS3 = true;
         CancelarTodasLasPendientes();
         datetime tNow = iTime(_Symbol, PERIOD_M5, 0);
         DibujarNivelEstructura("NOVA_S3_BLOCK_" + TimeToString(tNow), tNow, g_RangeMid, "SETUP 3 BLOQUEO", clrRed, true);
        }
      m.stage = QE_FINISHED;
     }
  }

void AplicarTrailingMotorQe(ulong ticket, long posType, double openPrice, double curSL, double curTP, double currentRR, double initRisk)
  {
   if(!InpExit_Trailing) return;

   if(InpUseOptimizedTrail)
     {
      if(currentRR >= 0.65 && currentRR < 1.00)
         MoverSLSeguro(ticket, posType, curSL, openPrice, curTP, "TRAIL_OPT");
      else if(currentRR >= 1.00 && currentRR < 1.50)
         MoverSLSeguro(ticket, posType, curSL, (posType == POSITION_TYPE_BUY) ? openPrice + initRisk * 0.50 : openPrice - initRisk * 0.50, curTP, "TRAIL_OPT");
      else if(currentRR >= 1.50 && currentRR < 2.00)
         MoverSLSeguro(ticket, posType, curSL, (posType == POSITION_TYPE_BUY) ? openPrice + initRisk * 1.00 : openPrice - initRisk * 1.00, curTP, "TRAIL_OPT");
      else if(currentRR >= 2.00)
        {
         double structSL = ObtenerSoportesResistenciasM5(posType);
         if(structSL > 0) MoverSLSeguro(ticket, posType, curSL, structSL, curTP, "TRAIL_OPT_EST");
        }
     }
   else
     {
      if(currentRR >= 0.50 && currentRR < 0.80)
         MoverSLSeguro(ticket, posType, curSL, (posType == POSITION_TYPE_BUY) ? openPrice - initRisk * 0.25 : openPrice + initRisk * 0.25, curTP, "TRAIL");
      else if(currentRR >= 0.80 && currentRR < 1.80)
         MoverSLSeguro(ticket, posType, curSL, (posType == POSITION_TYPE_BUY) ? openPrice + initRisk * 0.50 : openPrice - initRisk * 0.50, curTP, "TRAIL");
      else if(currentRR >= 1.80 && currentRR < 2.00)
         MoverSLSeguro(ticket, posType, curSL, (posType == POSITION_TYPE_BUY) ? openPrice + initRisk * 1.10 : openPrice - initRisk * 1.10, curTP, "TRAIL");
      else if(currentRR >= 2.00)
        {
         double structSL = ObtenerSoportesResistenciasM5(posType);
         if(structSL > 0) MoverSLSeguro(ticket, posType, curSL, structSL, curTP, "TRAIL_EST");
        }
     }
  }

void GestionarSetup2Nacimiento(datetime nyTime, datetime srvTime, datetime nyLastEntry)
  {
   MqlDateTime dt; TimeToStruct(nyTime, dt);
   int minsNY = dt.hour * 60 + dt.min;
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
         bool invalidado = (g_S2NDir == 1 && curBid < g_S2NExtreme) || (g_S2NDir == -1 && curAsk > g_S2NExtreme);

         if(nyTime > nyLastEntry || invalidado)
           {
            trade.OrderDelete(ticket);
            tienePendiente = false;
            g_S2NStage = (nyTime > nyLastEntry) ? S2N_FINISHED : S2N_WAIT_1QR;
           }
        }
     }

   bool tienePosicion = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol && (ulong)PositionGetInteger(POSITION_MAGIC) == MAGIC_S2_NAC)
        {
         tienePosicion = true;
         bool esNuevaPos = (g_S2NStage != S2N_IN_TRADE);
         if(esNuevaPos) g_S2NStage = S2N_IN_TRADE;

         long   posType   = PositionGetInteger(POSITION_TYPE);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double curSL     = PositionGetDouble(POSITION_SL);
         double curTP     = PositionGetDouble(POSITION_TP);

         double curPrice  = (posType == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double diffPrice = (posType == POSITION_TYPE_BUY) ? (curPrice - openPrice) : (openPrice - curPrice);
         double currentRR = (g_S2NInitRisk > 0) ? (diffPrice / g_S2NInitRisk) : 0.0;
         int    dirPos    = (posType == POSITION_TYPE_BUY) ? 1 : -1;

         if(esNuevaPos)
            TraceEv("FILL", "S2N", dirPos, openPrice, curSL, curTP, g_S2NInitRisk,
                    "ticket=" + IntegerToString((long)ticket));

         if(InpExit_EndOfDay && minsNY >= (15 * 60 + 40) && currentRR <= 0.15)
           {
            trade.PositionClose(ticket);
            TraceEv("EXIT", "S2N", dirPos, curPrice, openPrice, currentRR, 0.0,
                    "EOD_1540 ticket=" + IntegerToString((long)ticket));
            g_S2NStage = S2N_FINISHED;
            continue;
           }

         if(InpExit_Open930 && InpFilter930Open && minsNY == (9 * 60 + 29) && !g_S2NOpen930Done)
           {
            g_S2NOpen930Done = true;
            if(currentRR >= -0.10 && currentRR <= 0.15)
              {
               trade.PositionClose(ticket);
               TraceEv("EXIT", "S2N", dirPos, curPrice, openPrice, currentRR, 0.0,
                       "OPEN930_FLAT ticket=" + IntegerToString((long)ticket));
               g_S2NStage = S2N_FINISHED;
               continue;
              }
            else if(currentRR > 0.15)
              {
               double sl930 = (posType == POSITION_TYPE_BUY) ? openPrice - g_S2NInitRisk * 0.25 : openPrice + g_S2NInitRisk * 0.25;
               MoverSLSeguro(ticket, posType, curSL, sl930, curTP, "OPEN930");
              }
           }

         bool tocoFinalRango = (posType == POSITION_TYPE_BUY) ? (curPrice >= g_RangeHigh) : (curPrice <= g_RangeLow);
         if(InpExit_S2N_BE && tocoFinalRango && currentRR < 0.40)
            MoverSLSeguro(ticket, posType, curSL, (posType == POSITION_TYPE_BUY) ? openPrice - g_S2NInitRisk * 0.50 : openPrice + g_S2NInitRisk * 0.50, curTP, "S2N_BE0");

         double salidaFinal = (posType == POSITION_TYPE_BUY) ? (curPrice - g_RangeHigh) : (g_RangeLow - curPrice);
         if(InpExit_S2N_BE && salidaFinal >= (g_S2NInitRisk * 0.15) && currentRR < 0.80)
            MoverSLSeguro(ticket, posType, curSL, openPrice, curTP, "S2N_BE");

         if(InpExit_Trailing)
           {
            if(currentRR >= 0.80 && currentRR < 1.10)
               MoverSLSeguro(ticket, posType, curSL, (posType == POSITION_TYPE_BUY) ? openPrice + g_S2NInitRisk * 0.50 : openPrice - g_S2NInitRisk * 0.50, curTP, "S2N_TRAIL");
            else if(currentRR >= 1.10)
              {
               if(!TieneMomentumClaroM5(posType))
                 {
                  trade.PositionClose(ticket);
                  TraceEv("EXIT", "S2N", dirPos, curPrice, openPrice, currentRR, 0.0,
                          "S2N_NO_MOMENTUM ticket=" + IntegerToString((long)ticket));
                  g_S2NStage = S2N_FINISHED;
                  continue;
                 }
               double mult = (currentRR >= 1.25) ? 1.10 : 0.80;
               MoverSLSeguro(ticket, posType, curSL, (posType == POSITION_TYPE_BUY) ? openPrice + g_S2NInitRisk * mult : openPrice - g_S2NInitRisk * mult, curTP, "S2N_TRAIL");
              }
           }
        }
     }

   if(!tienePosicion && !tienePendiente && (g_S2NStage == S2N_IN_TRADE || g_S2NStage == S2N_ORDER_ACTIVE))
      g_S2NStage = S2N_FINISHED;
  }

//+------------------------------------------------------------------+
//| 7. UTILIDADES DE RIESGO, NOTICIAS Y GRÁFICOS                     |
//+------------------------------------------------------------------+
bool TieneMomentumClaroM5(long posType)
  {
   double o0 = iOpen(_Symbol, PERIOD_M5, 0), c0 = iClose(_Symbol, PERIOD_M5, 0);
   double cuerpoActual = MathAbs(c0 - o0);
   double suma = 0.0;
   for(int i = 1; i <= 10; i++)
      suma += MathAbs(iClose(_Symbol, PERIOD_M5, i) - iOpen(_Symbol, PERIOD_M5, i));
   bool dirOk = (posType == POSITION_TYPE_BUY) ? (c0 > o0) : (c0 < o0);
   return (dirOk && cuerpoActual > (suma / 10.0) * 1.5);
  }

bool UltimoTradeCerroEnPerdida(ulong magic)
  {
   if(!HistorySelect(TimeCurrent() - 86400, TimeCurrent())) return false;
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ulong dealTicket = HistoryDealGetTicket(i);
      if((ulong)HistoryDealGetInteger(dealTicket, DEAL_MAGIC) == magic &&
         HistoryDealGetInteger(dealTicket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
         return (HistoryDealGetDouble(dealTicket, DEAL_PROFIT) < 0.0);
     }
   return false;
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

void MoverSLSeguro(ulong ticket, long posType, double curSL, double newSL, double curTP, string reason = "")
  {
   newSL = NormalizeDouble(newSL, _Digits);
   double minStop = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;

   if(posType == POSITION_TYPE_BUY)
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(newSL > curSL + _Point && newSL < (bid - minStop))
        {
         bool ok = trade.PositionModify(ticket, newSL, curTP);
         TraceEv(ok ? "SLMOVE" : "SLFAIL", reason, 1, newSL, curSL, bid, 0,
                 ok ? "" : "ret=" + IntegerToString(trade.ResultRetcode()) + " " + trade.ResultRetcodeDescription());
        }
     }
   else
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if((curSL == 0.0 || newSL < curSL - _Point) && newSL > (ask + minStop))
        {
         bool ok = trade.PositionModify(ticket, newSL, curTP);
         TraceEv(ok ? "SLMOVE" : "SLFAIL", reason, -1, newSL, curSL, ask, 0,
                 ok ? "" : "ret=" + IntegerToString(trade.ResultRetcode()) + " " + trade.ResultRetcodeDescription());
        }
     }
  }

double ObtenerSoportesResistenciasM5(long posType)
  {
   if(posType == POSITION_TYPE_BUY)
     {
      double lows[];
      if(CopyLow(_Symbol, PERIOD_M5, 1, 6, lows) == 6)
         return lows[ArrayMinimum(lows)] - (_Point * 10);
     }
   else
     {
      double highs[];
      if(CopyHigh(_Symbol, PERIOD_M5, 1, 6, highs) == 6)
         return highs[ArrayMaximum(highs)] + (_Point * 10);
     }
   return 0.0;
  }

double CalcularLotajePorRiesgo(double distanciaSL, double entryPrice, double slPrice, ENUM_ORDER_TYPE oType)
  {
   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double riesgoUSD = balance * (InpRiskPercent / 100.0);
   double minLot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(distanciaSL <= 0.0 || stepLot <= 0.0) return minLot;

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

   if(valorPorLote <= 0.0) return minLot;

   double lotesCrudos = riesgoUSD / valorPorLote;
   double lotesNorm   = MathFloor(lotesCrudos / stepLot) * stepLot;
   if(lotesNorm < minLot) lotesNorm = minLot;
   if(lotesNorm > maxLot) lotesNorm = maxLot;
   return NormalizeDouble(lotesNorm, 2);
  }

void ActualizarCalendarioNoticias(bool forzar)
  {
   if(!forzar && (TimeCurrent() - g_LastNewsFetch) < 1800) return;
   string url = "https://nfs.faireconomy.media/ff_calendar_thisweek.xml";
   char post[], result[]; string headers;
   ResetLastError();
   int res = WebRequest("GET", url, "", "", 5000, post, 0, result, headers);
   if(res == -1) { g_NewsStatus = (GetLastError() == 4060) ? "Habilitar URL en MT5" : "Error red"; return; }

   string xml = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   ArrayResize(g_NewsList, 0);
   int pos = 0;
   while(true)
     {
      int evStart = StringFind(xml, "<event>", pos); if(evStart < 0) break;
      int evEnd   = StringFind(xml, "</event>", evStart); if(evEnd < 0) break;
      string block = StringSubstr(xml, evStart, evEnd - evStart);
      if(ExtractTag(block, "impact") == "High" && (InpNewsCurrency == "" || StringFind(InpNewsCurrency, ExtractTag(block, "country")) >= 0))
        {
         datetime dtNY = ParseFFDateTime(ExtractTag(block, "date"), ExtractTag(block, "time"));
         if(dtNY > 0)
           {
            int idx = ArraySize(g_NewsList); ArrayResize(g_NewsList, idx + 1);
            g_NewsList[idx].timeNY = dtNY; g_NewsList[idx].title = ExtractTag(block, "title");
           }
        }
      pos = evEnd + 8;
     }
   g_LastNewsFetch = TimeCurrent();
   g_NewsStatus = "OK (" + IntegerToString(ArraySize(g_NewsList)) + " rojas semana)";
  }

bool EstaBloqueadoPorNoticias(datetime nyTime)
  {
   if(!InpUseNewsFilter) { g_NewsStatus = "Desactivado"; return false; }
   if(MQLInfoInteger(MQL_TESTER)) { g_NewsStatus = "Modo Backtest"; return false; }
   datetime proximaHora = 0; string proximaTitulo = "";
   for(int i = 0; i < ArraySize(g_NewsList); i++)
     {
      if(nyTime >= g_NewsList[i].timeNY - InpNewsMinsBefore * 60 && nyTime <= g_NewsList[i].timeNY + InpNewsMinsAfter * 60)
        { g_NextNewsInfo = "AHORA: " + g_NewsList[i].title; return true; }
      if(g_NewsList[i].timeNY > nyTime && (proximaHora == 0 || g_NewsList[i].timeNY < proximaHora))
        { proximaHora = g_NewsList[i].timeNY; proximaTitulo = g_NewsList[i].title; }
     }
   g_NextNewsInfo = (proximaHora > 0) ? TimeToString(proximaHora, TIME_DATE|TIME_MINUTES) + " NY - " + proximaTitulo : "Sin más rojas semana";
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
   MqlDateTime dt; ZeroMemory(dt);
   dt.year = (int)StringToInteger(d[2]); dt.mon = (int)StringToInteger(d[0]); dt.day = (int)StringToInteger(d[1]);
   dt.hour = hour; dt.min = (int)StringToInteger(t[1]);
   return StructToTime(dt);
  }

void CalcularRango(datetime startSrv, datetime endSrv)
  {
   double highs[], lows[];
   if(CopyHigh(_Symbol, PERIOD_M5, startSrv, endSrv, highs) <= 0 || CopyLow(_Symbol, PERIOD_M5, startSrv, endSrv, lows) <= 0) return;
   int idxMax = ArrayMaximum(highs), idxMin = ArrayMinimum(lows);
   if(idxMax >= 0 && idxMin >= 0)
     {
      g_RangeHigh = highs[idxMax]; g_RangeLow = lows[idxMin];
      g_RangeMid  = (g_RangeHigh + g_RangeLow) / 2.0;
      g_RangePct  = ((g_RangeHigh - g_RangeLow) / g_RangeLow) * 100.0;
     }
  }

//+------------------------------------------------------------------+
//| 8. INTERFAZ VISUAL Y PANEL HUD DE ALTO CONTRASTE                 |
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

void ActualizarHUD(datetime nyTime, string estado, color clrEstado)
  {
   int x = 14, y = 24, w = 410, h = 212;
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
   string rangoTxt  = (g_RangeHigh > 0) ?
                      DoubleToString(g_RangeHigh, _Digits) + " - " + DoubleToString(g_RangeLow, _Digits) + " (" + DoubleToString(g_RangePct, 2) + "%)" :
                      "Calculando...";

   SetHudLine(0, x + 12, y + 10,  "NOVA BOT v3.11   |   NAS100 M5", clrGold, 9, true);
   SetHudLine(1, x + 12, y + 32,  "NY: " + TimeToString(nyTime, TIME_DATE|TIME_MINUTES) + "  |  " + estado, clrEstado, 8, false);
   SetHudLine(2, x + 12, y + 50,  "Rango 02-07:  " + rangoTxt, clrWhite, 8, false);
   SetHudLine(3, x + 12, y + 68,  "Riesgo / Op:  " + DoubleToString(InpRiskPercent, 2) + "%  ($" + DoubleToString(riesgoUSD, 2) + ")", clrSilver, 8, false);

   SetHudLine(4, x + 12, y + 92,  "Setup 1:      " + FormatearEstadoQe(g_S1, InpEnableSetup1), ColorEstadoQe(g_S1.stage, InpEnableSetup1), 8, false);
   SetHudLine(5, x + 12, y + 110, "Setup 2 Nac:  " + FormatearEstadoS2N(), ColorEstadoS2N(), 8, false);
   SetHudLine(6, x + 12, y + 128, "Setup 2 Cont: " + FormatearEstadoQe(g_S2C, InpEnableSetup2Cont), ColorEstadoQe(g_S2C.stage, InpEnableSetup2Cont), 8, false);
   SetHudLine(7, x + 12, y + 146, "Setup 3 Stop: " + (g_SessionBlockedS3 ? "ACTIVADO (DÍA CERRADO)" : "OK (Operativa Habilitada)"), g_SessionBlockedS3 ? clrTomato : clrLimeGreen, 8, false);

   SetHudLine(8, x + 12, y + 170, "Bullfy News:  " + g_NewsStatus, clrSilver, 8, false);
   SetHudLine(9, x + 12, y + 188, "Próx. Roja:   " + g_NextNewsInfo, clrWhite, 8, false);
  }

void SetHudLine(int idx, int x, int y, string text, color clr, int fontSize, bool bold)
  {
   string name = "NOVA_HUD_L" + IntegerToString(idx);
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
     }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
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
   if(st == QE_ORDER_ACTIVE || st == QE_WAIT_2QE_PB || st == QE_WAIT_2QE_BRK) return clrGold;
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
   if(g_S2NStage == S2N_ORDER_ACTIVE || g_S2NStage == S2N_WAIT_CH_CONFIRM) return clrGold;
   if(g_S2NStage == S2N_FINISHED) return clrGray;
   return clrWhite;
  }
//+------------------------------------------------------------------+