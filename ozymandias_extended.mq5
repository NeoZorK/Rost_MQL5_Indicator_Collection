//+------------------------------------------------------------------+
//|                  Ozymandias_Extended (PunkBASSter's edition).mq5 |
//|                                     Copyright © 2014, GoldnMoney |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, GoldnMoney"
#property link "http://www.mql5.com"
//---
#property version   "1.00"
#property indicator_chart_window 
#property indicator_buffers 4 
#property indicator_plots   3
//---
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---
#property indicator_color1  clrDeepPink,clrDodgerBlue
#property indicator_color2  clrRosyBrown
#property indicator_color3  clrRosyBrown
//---
#property indicator_style1  STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---
#property indicator_width1  3
#property indicator_width2  2
#property indicator_width3  2
//---
#property indicator_label1  "Ozymandias"
#property indicator_label2  "Upper Ozymandias"
#property indicator_label3  "Lower Ozymandias"
//---
#define RESET  0
//---
input uint Length=2;
input  ENUM_MA_METHOD MAType=MODE_SMA;
input int Shift=0;
input double ChannelRatio=1;
input int AtrPeriod=100;
//---
double IndBuffer[],ColorIndBuffer[];
double UpBuffer[],DnBuffer[];
//---
int min_rates_total;
int ATR_Handle,HMA_Handle,LMA_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---
   min_rates_total=int(Length);
   ATR_Handle=iATR(NULL,0,AtrPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---
   HMA_Handle=iMA(NULL,0,Length,0,MAType,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//---
   LMA_Handle=iMA(NULL,0,Length,0,MAType,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//---
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
   ArraySetAsSeries(IndBuffer,true);
//---
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(ColorIndBuffer,true);
//---
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---
   SetIndexBuffer(2,UpBuffer,INDICATOR_DATA);
   ArraySetAsSeries(UpBuffer,true);
//---
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---
   SetIndexBuffer(3,DnBuffer,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(DnBuffer,true);
//---
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Ozymandias");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   return(INIT_SUCCEEDED);
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- объявление переменных
   int to_copy,limit,trend0,nexttrend0;
   double hh,ll,maxl0,minh0,lma,hma,atr,ATR[],HMA[],LMA[];
   static int trend1,nexttrend1;
   static double maxl1,minh1;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      trend1=0;
      nexttrend1=0;
      maxl1=0;
      minh1=9999999;
     }
   else limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
   to_copy=limit+1;
//---
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);
//---
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);
//---
   nexttrend0=nexttrend1;
   maxl0=maxl1;
   minh0=minh1;
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      hh=high[ArrayMaximum(high,bar,Length)];
      ll=low[ArrayMinimum(low,bar,Length)];
      lma=LMA[bar];
      hma=HMA[bar];
      atr=ATR[bar];
      trend0=trend1;
      //---
      if(nexttrend0==1)
        {
         maxl0=MathMax(ll,maxl0);

         if(hma<maxl0 && close[bar]<low[bar+1])
           {
            trend0=1;
            nexttrend0=0;
            minh0=hh;
           }
        }
      //---
      if(nexttrend0==0)
        {
         minh0=MathMin(hh,minh0);

         if(lma>minh0 && close[bar]>high[bar+1])
           {
            trend0=0;
            nexttrend0=1;
            maxl0=ll;
           }
        }
      //---
      if(trend0==0)
        {
         if(trend1!=0.0)
           {
            IndBuffer[bar]=IndBuffer[bar+1];
            ColorIndBuffer[bar]=1;
           }
         else
           {
            IndBuffer[bar]=MathMax(maxl0,IndBuffer[bar+1]);
            ColorIndBuffer[bar]=1;
           }
         UpBuffer[bar]=IndBuffer[bar]+atr*ChannelRatio;
         DnBuffer[bar]=IndBuffer[bar]-atr*ChannelRatio;
        }
      else
        {
         if(trend1!=1)
           {
            IndBuffer[bar]=IndBuffer[bar+1];
            ColorIndBuffer[bar]=0;
           }
         else
           {
            IndBuffer[bar]=MathMin(minh0,IndBuffer[bar+1]);
            ColorIndBuffer[bar]=0;
           }
         UpBuffer[bar]=IndBuffer[bar]+atr*ChannelRatio;
         DnBuffer[bar]=IndBuffer[bar]-atr*ChannelRatio;
        }
      //---
      if(bar)
        {
         nexttrend1=nexttrend0;
         trend1=trend0;
         maxl1=maxl0;
         minh1=minh0;
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
