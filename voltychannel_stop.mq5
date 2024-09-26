//+------------------------------------------------------------------+
//|                                            VoltyChannel_Stop.mq5 |
//|                                Copyright © 2007, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2007, TrendLaboratory"
//---- link to the website of the author
#property link "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- SeaGreen color is used as the color of the indicator line
#property indicator_color1  clrSeaGreen
//---- the indicator 1 line is a dot-dash one
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator line label
#property indicator_label1  "Upper VoltyChannel_Stop"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- MediumVioletRedcolor is used for the indicator line
#property indicator_color2  clrMediumVioletRed
//---- the indicator 2 line is a dot-dash one
#property indicator_style2  STYLE_DASHDOTDOT
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator line label
#property indicator_label2  "Lower VoltyChannel_Stop"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//---- LightSeaGreen color is used for the indicator
#property indicator_color3  clrLightSeaGreen
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3  "Buy VoltyChannel_Stop"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//---- Red color is used for the indicator
#property indicator_color4  clrRed
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying the indicator label
#property indicator_label4  "Sell VoltyChannel_Stop"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // the constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int                MAPeriod=1;
input  ENUM_MA_METHOD    MAType=MODE_EMA;
input ENUM_APPLIED_PRICE MAPrice=PRICE_CLOSE;

input int     ATRPeriod=10;                     // ATR's Period
input double  Kv=4;                             // Volatility's Factor or Multiplier
input double  MoneyRisk=1;                      // Offset Factor 
input bool    usePrice_HiLoBreak=true;
input bool    useMA_HiLoEnvelope=false;

input bool bAlert=true;                         // allowance to send alerts
input bool bPush=true;                          // allowance to send push messages
input string  PushComment="VoltyChannel_Stop";  // first part of the comment
input int      Shift=0;                         // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//---- declaration of integer variables for indicators handles
int ATR_Handle,MA_Handle,LMA_Handle,HMA_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
string sBuySignal,sSellSignal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- getting handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(1);
     }

   if(useMA_HiLoEnvelope)
     {
      //---- getting handle of the LMA indicator
      LMA_Handle=iMA(NULL,0,MAPeriod,0,MAType,PRICE_LOW);
      if(LMA_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the LMA indicator");
         return(1);
        }

      //---- getting handle of the HMA indicator
      HMA_Handle=iMA(NULL,0,MAPeriod,0,MAType,PRICE_HIGH);
      if(HMA_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the HMA indicator");
         return(1);
        }
     }
   else
     {
      //---- getting handle of the MA indicator
      MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
      if(MA_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the MA indicator");
         return(1);
        }
     }

//---- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(ATRPeriod,MAPeriod)+1);

//---- initialization of variables for trade signals   
   string text=PushComment+": "+Symbol();
   sBuySignal=text+" Buy signal";
   sSellSignal=text+" Sell signal";

//---- set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set ExtMapBufferUp1[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,89);

//---- set ExtMapBufferDown1[] dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,89);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"VoltyChannel_Stop");
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

   if(useMA_HiLoEnvelope)
     {
      if(BarsCalculated(HMA_Handle)<rates_total || BarsCalculated(LMA_Handle)<rates_total) return(RESET);
     }
   else
     {
      if(BarsCalculated(MA_Handle)<rates_total) return(RESET);
     }

//---- declaration of local variables 
   double ATR[],HMA[],LMA[],MA[],bprice,sprice,smax0,smin0;
   int limit,to_copy,trend0,bar;
   static double smax1,smin1;
   static int trend1;
   string Text;

//---- indexing elements in arrays as in time series  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);

//---- calculation of the limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1;               // starting index for calculation of all bars
      trend1=0;
      smax1=0.0;
      smin1=999999999.9;    
     }
   else
     {
      limit=rates_total-prev_calculated;                 // starting index for calculation of new bars
     }

   to_copy=limit+1;
//---- copy newly appeared data into the arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

   if(useMA_HiLoEnvelope)
     {
      if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
      if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);
     }
   else
     {
      if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
     }

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0; bar--)
     {
      ExtMapBufferUp[bar]=0.0;
      ExtMapBufferDown[bar]=0.0;
      ExtMapBufferUp1[bar]=0.0;
      ExtMapBufferDown1[bar]=0.0;

      if(useMA_HiLoEnvelope)
        {
         bprice=HMA[bar];
         sprice=LMA[bar];
        }
      else
        {
         bprice=MA[bar];
         sprice=bprice;
        }

      double res=Kv*ATR[bar];
      smax0=bprice+res;
      smin0=sprice-res;
      trend0=trend1;

      if(usePrice_HiLoBreak)
        {
         if(high[bar]>smax1) trend0=+1;
         if(low[bar]<smin1) trend0=-1;
        }
      else
        {
         if(bprice>smax1) trend0=+1;
         if(sprice<smin1) trend0=-1;
        }

      if(trend0>0)
        {
         if(smin0<smin1) smin0=smin1;
         ExtMapBufferUp[bar]=smin0-(MoneyRisk-1)*ATR[bar];
         if(ExtMapBufferUp[bar]<ExtMapBufferUp[bar+1] && ExtMapBufferUp[bar+1]) ExtMapBufferUp[bar]=ExtMapBufferUp[bar+1];
         if(trend1!=trend0) ExtMapBufferUp1[bar]=ExtMapBufferUp[bar];
        }

      if(trend0<0)
        {
         if(smax0>smax1) smax0=smax1;
         ExtMapBufferDown[bar]=smax0+(MoneyRisk-1)*ATR[bar];
         if(ExtMapBufferDown[bar]>ExtMapBufferDown[bar+1] && ExtMapBufferDown[bar+1]) ExtMapBufferDown[bar]=ExtMapBufferDown[bar+1];
         if(trend1!=trend0) ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];
        }
        
       if(bar==1)
        {
         if(trend1<0 && trend0>0)
           {
            Text=sBuySignal+TimeToString(time[1],TIME_DATE|TIME_MINUTES);
            if(bPush) SendNotification(Text);
            if(bAlert) Alert(Text);
           }
           
         if(trend1>0 && trend0<0)
           {
            Text=sSellSignal+TimeToString(time[1],TIME_DATE|TIME_MINUTES);
            if(bPush) SendNotification(Text);
            if(bAlert) Alert(Text);
           }
        }
        
      if(bar)
        {
         smax1=smax0;
         smin1=smin0;
         trend1=trend0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
