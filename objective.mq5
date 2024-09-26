//+------------------------------------------------------------------+
//|                                                    Objective.mq5 | 
//|                                         Copyright © 2011, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, LeMan."
#property link      "b-market@mail.ru"
#property description "Objective"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define LINES_TOTAL    8 // Константа для количества линий индикатора
#define RESET          0 // Константа для возврата терминалу команды на пересчет индикатора
//---- количество индикаторных буферов
#property indicator_buffers LINES_TOTAL 
//---- использовано всего графических построений
#property indicator_plots   LINES_TOTAL
//+-----------------------------------+
//|  Параметры отрисовки индикаторов  |
//+-----------------------------------+
//---- отрисовка индикаторов в виде линий
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//---- выбор цветов линий
#property indicator_color1  Red
#property indicator_color2  Red
#property indicator_color3  Red
#property indicator_color4  Red
#property indicator_color5  Green
#property indicator_color6  Green
#property indicator_color7  Green
#property indicator_color8  Green
//---- линии - штрихпунктирные кривые
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_DASHDOTDOT
//---- толщина линий 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum ENUM_APPLIED_PRICE_ // Тип константы
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  Входные параметры индикатора     |
//+-----------------------------------+
input int Sample=20;
input int Quartile_1 = 25;
input int Quartile_2 = 50;
input int Quartile_3 = 75;
input int Shift=0;     // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление глобальных переменных
int n0,n1,n2,n3;
double HOArray[],OLArray[];
//---- Объявление целочисленных переменных начала отсчета данных
int min_rates_total,N_;
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных буферов            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных буферов            |
//+------------------------------------------------------------------+  
int GetValue(string InValueName,int InValue)
  {
//----
   if(InValue>100)
     {
      Print("Параметр "+InValueName+" не может быть больше 100! Будет использовано значение по умолчанию, равное 100!");
      return(100);
     }
   if(InValue<0)
     {
      Print("Параметр "+InValueName+" не может быть меньше 0! Будет использовано значение по умолчанию, равное 0!");
      return(0);
     }
//----
   return(InValue);
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация констант
   double P1=GetValue("Quartile_1",Quartile_1);
   double P2=GetValue("Quartile_2",Quartile_2);
   double P3=GetValue("Quartile_3",Quartile_3);

   N_=Sample;
   if(N_<3){N_=3;Print("Параметр Sample не может быть меньше 3! Будет использовано значение по умолчанию, равное 3!");}

   min_rates_total=N_;
   n0=N_-1;
   n1=int(MathRound(N_*P1/100)); if(!n1) n1=100;
   n2=int(MathRound(N_*P2/100)); if(!n2) n2=100;
   n3=int(MathRound(N_*P3/100)); if(!n3) n3=100;

//---- распределение памяти под массивы переменных
   if(ArrayResize(HOArray,N_)<N_) Print("Не удалось распределить память под массив HOArray[]");
   if(ArrayResize(OLArray,N_)<N_) Print("Не удалось распределить память под массив OLArray[]");

//----
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      string shortname="";
      StringConcatenate(shortname,"Ouartile ",numb+1,")");
      //--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- установка значений индикатора, которые не будут видимы на графике
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- осуществление сдвига начала отсчета отрисовки индикатора
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- осуществление сдвига индикатора 1 по горизонтали на Shift
      PlotIndexSetInteger(numb,PLOT_SHIFT,Shift);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(numb,Ind[numb].IndBuffer,INDICATOR_DATA);
     }

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Objective");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//---- объявление целочисленных переменных
   int first,bar;
   double q[8];

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated==0) // проверка на первый старт расчета индикатора
     {
      first=min_rates_total-1;  // стартовый номер для расчета всех баров
     }
   else
     {
      first=prev_calculated-1;  // стартовый номер для расчета новых баров
     }

//---- основной цикл расчета
   for(bar=first; bar<rates_total; bar++)
     {
      for(int kkk=0; kkk<N_; kkk++) HOArray[kkk]=high[bar-kkk]-open[bar-kkk];
      for(int kkk=0; kkk<N_; kkk++) OLArray[kkk]=open[bar-kkk]-low [bar-kkk];

      ArraySort(HOArray);
      ArraySort(OLArray);

      q[0] = -OLArray[n1];
      q[1] = -OLArray[n2];
      q[2] = -OLArray[n3];
      q[3] = -OLArray[n0];
      q[4] = +HOArray[n1];
      q[5] = +HOArray[n2];
      q[6] = +HOArray[n3];
      q[7] = +HOArray[n0];

      for(int numb=0; numb<LINES_TOTAL; numb++) Ind[numb].IndBuffer[bar]=open[bar]+q[numb];
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
