//+------------------------------------------------------------------+
//|                                                    Objective.mq5 | 
//|                                         Copyright � 2011, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2011, LeMan."
#property link      "b-market@mail.ru"
#property description "Objective"
//---- ����� ������ ����������
#property version   "1.00"
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//+-----------------------------------+
//|  ���������� ��������              |
//+-----------------------------------+
#define LINES_TOTAL    8 // ��������� ��� ���������� ����� ����������
#define RESET          0 // ��������� ��� �������� ��������� ������� �� �������� ����������
//---- ���������� ������������ �������
#property indicator_buffers LINES_TOTAL 
//---- ������������ ����� ����������� ����������
#property indicator_plots   LINES_TOTAL
//+-----------------------------------+
//|  ��������� ��������� �����������  |
//+-----------------------------------+
//---- ��������� ����������� � ���� �����
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//---- ����� ������ �����
#property indicator_color1  Red
#property indicator_color2  Red
#property indicator_color3  Red
#property indicator_color4  Red
#property indicator_color5  Green
#property indicator_color6  Green
#property indicator_color7  Green
#property indicator_color8  Green
//---- ����� - ��������������� ������
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_DASHDOTDOT
//---- ������� ����� 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//+-----------------------------------+
//|  ���������� ������������          |
//+-----------------------------------+
enum ENUM_APPLIED_PRICE_ // ��� ���������
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
//|  ������� ��������� ����������     |
//+-----------------------------------+
input int Sample=20;
input int Quartile_1 = 25;
input int Quartile_2 = 50;
input int Quartile_3 = 75;
input int Shift=0;     // ����� ���������� �� ����������� � �����
//+-----------------------------------+
//---- ���������� ���������� ����������
int n0,n1,n2,n3;
double HOArray[],OLArray[];
//---- ���������� ������������� ���������� ������ ������� ������
int min_rates_total,N_;
//+------------------------------------------------------------------+
//|  ������� ���������� ��� �������� ������������ �������            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| �������� ������������ �������                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+
//|  ������� ���������� ��� �������� ������������ �������            |
//+------------------------------------------------------------------+  
int GetValue(string InValueName,int InValue)
  {
//----
   if(InValue>100)
     {
      Print("�������� "+InValueName+" �� ����� ���� ������ 100! ����� ������������ �������� �� ���������, ������ 100!");
      return(100);
     }
   if(InValue<0)
     {
      Print("�������� "+InValueName+" �� ����� ���� ������ 0! ����� ������������ �������� �� ���������, ������ 0!");
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
//---- ������������� ��������
   double P1=GetValue("Quartile_1",Quartile_1);
   double P2=GetValue("Quartile_2",Quartile_2);
   double P3=GetValue("Quartile_3",Quartile_3);

   N_=Sample;
   if(N_<3){N_=3;Print("�������� Sample �� ����� ���� ������ 3! ����� ������������ �������� �� ���������, ������ 3!");}

   min_rates_total=N_;
   n0=N_-1;
   n1=int(MathRound(N_*P1/100)); if(!n1) n1=100;
   n2=int(MathRound(N_*P2/100)); if(!n2) n2=100;
   n3=int(MathRound(N_*P3/100)); if(!n3) n3=100;

//---- ������������� ������ ��� ������� ����������
   if(ArrayResize(HOArray,N_)<N_) Print("�� ������� ������������ ������ ��� ������ HOArray[]");
   if(ArrayResize(OLArray,N_)<N_) Print("�� ������� ������������ ������ ��� ������ OLArray[]");

//----
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      string shortname="";
      StringConcatenate(shortname,"Ouartile ",numb+1,")");
      //--- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- ��������� �������� ����������, ������� �� ����� ������ �� �������
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- ������������� ������ ������ ������� ��������� ����������
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- ������������� ������ ���������� 1 �� ����������� �� Shift
      PlotIndexSetInteger(numb,PLOT_SHIFT,Shift);
      //---- ����������� ������������ �������� � ������������ ������
      SetIndexBuffer(numb,Ind[numb].IndBuffer,INDICATOR_DATA);
     }

//--- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
   IndicatorSetString(INDICATOR_SHORTNAME,"Objective");

//--- ����������� �������� ����������� �������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- ���������� �������������
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // ���������� ������� � ����� �� ������� ����
                const int prev_calculated,// ���������� ������� � ����� �� ���������� ����
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- �������� ���������� ����� �� ������������� ��� �������
   if(rates_total<min_rates_total) return(0);

//---- ���������� ������������� ����������
   int first,bar;
   double q[8];

//---- ������ ���������� ������ first ��� ����� ��������� �����
   if(prev_calculated==0) // �������� �� ������ ����� ������� ����������
     {
      first=min_rates_total-1;  // ��������� ����� ��� ������� ���� �����
     }
   else
     {
      first=prev_calculated-1;  // ��������� ����� ��� ������� ����� �����
     }

//---- �������� ���� �������
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
