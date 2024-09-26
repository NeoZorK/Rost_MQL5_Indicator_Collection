//+------------------------------------------------------------------+
//|              Ozymandias_Extended_HTF (PunkBASSter's edition).mq5 |
//+------------------------------------------------------------------+
#property description "Ozymandias � ������������ ��������� �� � ���������� ������"
//---
#property indicator_chart_window 
#property indicator_buffers 4 
#property indicator_plots   3
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
//---
#property indicator_color1  clrDeepPink,clrDodgerBlue
#property indicator_color2  clrRosyBrown
#property indicator_color3  clrRosyBrown
//---
#property indicator_width1  3
#property indicator_width2  2
#property indicator_width3  2
//---
#property indicator_label1  "Ozymandias"
#property indicator_label2  "Upper Ozymandias"
#property indicator_label3  "Lower Ozymandias"
//---
#define RESET 0
#define INDICATOR_NAME "Ozymandias"
#define SIZE 1
//---
input    ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;
input    uint Length=2;
input    ENUM_MA_METHOD MAType=MODE_SMA;
input    int Shift=0;
input    double ChannelRatio=1; //ChannelAtrMultiplier
input    int AtrPeriod=100;
//---
double UpIndBuffer[];
double DnIndBuffer[];
double IndBuffer[];
double ColorIndBuffer[];
//---
int min_rates_total;
int Ind_Handle;
//---
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//---    
   min_rates_total=2;
//---
   Ind_Handle=iCustom(Symbol(),TimeFrame,"Ozymandias_Extended",Length,MAType,0,ChannelRatio,AtrPeriod);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� Ozymandias");
      return(INIT_FAILED);
     }
   IndInit(0,IndBuffer,INDICATOR_DATA);
   IndInit(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
   IndInit(2,UpIndBuffer,INDICATOR_DATA);
   IndInit(3,DnIndBuffer,INDICATOR_DATA);
//--- ������������� �����������
   PlotInit(0,EMPTY_VALUE,0,Shift);
   PlotInit(1,EMPTY_VALUE,0,Shift);
   PlotInit(2,EMPTY_VALUE,0,Shift);
//--- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- ���������� �������������
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,1,ColorIndBuffer,
      2,UpIndBuffer,3,DnIndBuffer,time,rates_total,prev_calculated,min_rates_total))
      return(RESET);
//---     
   return(rates_total);
  }
//-- �� ��������� https://www.mql5.com/ru/code/viewcode/12604/64355/ozymandias_htf.mq5
//+------------------------------------------------------------------+
//| ������������� ������������� ������                               |
//+------------------------------------------------------------------+
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
   SetIndexBuffer(Number,Buffer,Type);
   ArraySetAsSeries(Buffer,true);
  }
//+------------------------------------------------------------------+
//| ������������� ����������                                         |
//+------------------------------------------------------------------+    
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // ����� ������� CountLine �� ������ � ���� ���������� (��������� ����� - 0)
                    string   Symb,            // ������ �������
                    ENUM_TIMEFRAMES TFrame,   // ������ �������
                    int      IndHandle,       // ����� ��������������� ����������
                    uint     BuffNumb,        // ����� ������ ��������������� ���������� ��� ������� �����
                    double&  IndBuf[],        // �������� ����� ���������� ��� ������� �����
                    uint     ColBuffNumb,     // ����� ��������� ������ ��������������� ���������� ��� ������� �����
                    double&  ColIndBuf[],     // �������� �������� ����� ���������� ��� ������� �����
                    uint     UpBuffNumb,      // ����� �������� ������ ��������������� ���������� ��� ������
                    double&  UpIndBuf[],      // �������� ������� ����� ���������� ��� ������
                    uint     DnBuffNumb,      // ����� ������� ������ ��������������� ���������� ��� ������
                    double&  DnIndBuf[],      // �������� ������ ����� ���������� ��� ������
                    const datetime& iTime[],  // ��������� �������
                    const int Rates_Total,    // ���������� ������� � ����� �� ������� ����
                    const int Prev_Calculated,// ���������� ������� � ����� �� ���������� ����
                    const int Min_Rates_Total)// ����������� ���������� ������� � ����� ��� �������
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//---
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// �������� �� ������ ����� ������� ����������
     {
      limit=Rates_Total-Min_Rates_Total-1; // ��������� ����� ��� ������� ���� �����
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // ��������� ����� ��� ������� ����� ����� 
//--- �������� ���� ������� ����������
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- �������� ����� ����������� ������ � ������ IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1],ColArr[1],UpArr[1],DnArr[1];
         //--- �������� ����� ����������� ������ � �������
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,ColBuffNumb,iTime[bar],1,ColArr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,UpBuffNumb,iTime[bar],1,UpArr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,DnBuffNumb,iTime[bar],1,DnArr)<=0) return(RESET);
         //---
         IndBuf[bar]=Arr[0];
         ColIndBuf[bar]=ColArr[0];
         UpIndBuf[bar]=UpArr[0];
         DnIndBuf[bar]=DnArr[0];
        }
      else
        {
         int bar1=bar+1;
         IndBuf[bar]=IndBuf[bar1];
         ColIndBuf[bar]=ColIndBuf[bar1];
         UpIndBuf[bar]=UpIndBuf[bar1];
         DnIndBuf[bar]=DnIndBuf[bar1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,ENUM_TIMEFRAMES TFrame)
  {
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("������ ������� ��� ���������� "+IndName+" �� ����� ���� ������ ������� �������� �������!");
      Print("������� �������� ������� ��������� ����������!");
      return(RESET);
     }
   return(true);
  }
//+------------------------------------------------------------------+
