//+------------------------------------------------------------------+ 
//|                                                        Range.mq5 | 
//|                                 Copyright � 2005, Jason Robinson | 
//|                                      http://www.jnrtrading.co.uk | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright � 2005, Jason Robinson"
#property link "http://www.jnrtrading.co.uk" 
//---- ����� ������ ����������
#property version   "1.00"
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window 
//---- ���������� ������������ ������� 2
#property indicator_buffers 2 
//---- ������������ ����� ���� ����������� ����������
#property indicator_plots   1
//+-----------------------------------+
//|  ��������� ��������� ����������   |
//+-----------------------------------+
//---- ��������� ���������� � ���� ������������� �����������
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- � �������� ������ ���������� ����������� ������������
#property indicator_color1 clrChocolate,clrGray,clrDodgerBlue
//---- ����� ���������� - ��������
#property indicator_style1 STYLE_SOLID
//---- ������� ����� ���������� ����� 2
#property indicator_width1 2
//---- ����������� ����� ����������
#property indicator_label1 "Range"

//+-----------------------------------+
//|  ������� ��������� ����������     |
//+-----------------------------------+

//+-----------------------------------+
//---- ���������� ����� ���������� ������ ������� ������
int min_rates_total;
//---- ���������� ������������ ��������, ������� ����� � 
// ���������� ������������ � �������� ������������ �������
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| 2pbIdealXOSMA indicator initialization function                  | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- ������������� ���������� ������ ������� ������
   min_rates_total=2;

//---- ����������� ������������� ������� IndBuffer � ������������ �����
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- ������������� ������ ������ ������� ��������� ����������
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- ����������� ������������� ������� � ��������, ��������� �����   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//--- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
   IndicatorSetString(INDICATOR_SHORTNAME,"Range");
//--- ����������� �������� ����������� �������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- ���������� �������������
  }
//+------------------------------------------------------------------+  
//| 2pbIdealXOSMA iteration function                                 | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // ���������� ������� � ����� �� ������� ����
                const int prev_calculated,// ���������� ������� � ����� �� ���������� ����
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- �������� ���������� ����� �� ������������� ��� �������
   if(rates_total<min_rates_total) return(0);

///---- ���������� ��������� ���������� 
   int first,bar;
   uint Range,Prev_Range;
   uint clr;

//---- ������ ���������� ������ first ��� ����� ��������� �����
   if(prev_calculated>rates_total || prev_calculated<=0) // �������� �� ������ ����� ������� ����������
     {
      first=min_rates_total;  // ��������� ����� ��� ������� ���� �����
      IndBuffer[first-1]=(High[first-1]-Low[first-1])/_Point;
     }
   else first=prev_calculated-1; // ��������� ����� ��� ������� ����� �����

//---- �������� ���� ������� ����������
   for(bar=first; bar<rates_total; bar++)
     {
      Range=uint((High[bar]-Low[bar])/_Point);      
      IndBuffer[bar]=Range;
      Prev_Range=uint(IndBuffer[bar-1]);

      if(Range>Prev_Range) clr=2;
      else if(Range<Prev_Range) clr=0;
      else clr=1;
     
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
