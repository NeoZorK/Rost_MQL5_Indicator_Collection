//+------------------------------------------------------------------+
//|                                                     SpyAgent.mq5 |
//|                                                 Marcin Konieczny |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Marcin Konieczny"
#property indicator_chart_window
#property indicator_plots 0

input long   chart_id=0;        // id �������
input ushort custom_event_id=0; // id �������
//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {

   if(prev_calculated==0)
      EventChartCustom(chart_id,0,0,0.0,_Symbol); // �������� ������� �������������
   else
      EventChartCustom(chart_id,(ushort)(custom_event_id+1),0,0.0,_Symbol); // �������� ������� new tick

   return(rates_total);
  }
//+------------------------------------------------------------------+

