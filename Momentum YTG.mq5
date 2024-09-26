//+------------------------------------------------------------------+
//|                                                 Momentum YTG.mq5 |
//|                                               Iurii Tokman (YTG) |
//|                                                http://ytg.com.ua |
//+------------------------------------------------------------------+
#property copyright "Iurii Tokman (YTG)"
#property link      "http://ytg.com.ua"
#property version   "1.00"
#property indicator_separate_window

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_color2  clrGreen

input int MomentumPeriod=14;
double    B0[],B1[];
int       M_Period;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(MomentumPeriod<=0){
    M_Period=14;
    Print("Input parameter MomentumPeriod has wrong value. Indicator will use value ",M_Period);
   } else M_Period=MomentumPeriod;
  
   SetIndexBuffer(0,B0,INDICATOR_DATA);
   SetIndexBuffer(1,B1,INDICATOR_DATA);   
   IndicatorSetString(INDICATOR_SHORTNAME,"Momentum YTG"+"("+string(M_Period)+")"); 
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,M_Period-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,M_Period-1);   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);   
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   double res =0;
   int StartCalcPosition=(M_Period-1)+begin;
   if(rates_total<StartCalcPosition)return(0);

   int pos=prev_calculated-1;
   if(pos<StartCalcPosition)pos=begin+M_Period;

   for(int i=pos;i<rates_total && !IsStopped();i++){
    res = price[i]*100/price[i-M_Period] - 100.0;
    if(res<0)B0[i]=res;else B1[i]=res;}

   return(rates_total);
  }
//+------------------------------------------------------------------+
