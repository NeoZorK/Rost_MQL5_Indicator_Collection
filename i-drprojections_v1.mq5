//+------------------------------------------------------------------+
//|                                           i-DRProjections_v1.mq5 |
//|                                       KimIV, http://www.kimiv.ru |
//|                           Converted from MQL4 to MQL5 by igorad  |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+

#property copyright "KimIV"
#property link      "http://www.kimiv.ru"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Line Hi"
#property indicator_type1   DRAW_LINE
#property indicator_color1  SkyBlue

#property indicator_label2  "Line Lo"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Tomato


 
input int      NumberOfDays   =         1; //Number of days
input bool     ShowTomorrow   =      true;
input string   UniqueID       =  "DRProj";
input color    LineHiColor    =   SkyBlue;
input color    LineLoColor    =    Tomato;
input int      LineStyle      = STYLE_DOT;
input int      LineWidth      =         1;

//--- indicator buffers
double MaxDay[];
double MinDay[];

ENUM_TIMEFRAMES TimeFrame = PERIOD_D1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,MaxDay,INDICATOR_DATA); 
   SetIndexBuffer(1,MinDay,INDICATOR_DATA); 
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- 
   string short_name = "i-DRProjections_v1["+timeframeToString(TimeFrame)+"]("+(string)NumberOfDays+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

//---
   objCreate(UniqueID+"linehi",OBJ_TREND,LineStyle,1,LineWidth,LineHiColor);
   objCreate(UniqueID+"linelo",OBJ_TREND,LineStyle,1,LineWidth,LineLoColor);

//--- initialization done
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit( const int reason )
{
//---- 
   deleteObj (UniqueID);
   Comment("");
//----
   return;
}
//+------------------------------------------------------------------+
//| i-DRProjections_v1                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double   &Open[],
                const double   &High[],
                const double   &Low[],
                const double   &Close[],
                const long     &TickVolume[],
                const long     &Volume[],
                const int      &Spread[])
{
   int i = 0, j = 0, copied = 0, currDay;
   double open, high, low, close, price;
   
   if (Period() > PERIOD_H12) 
   {
   Comment("i-DRProjections does not support TimeFrame longer H12 !");
   return(0);
   }
   
      
//--- preliminary calculations
   if(prev_calculated == 0)  
   {
   ArrayInitialize(MaxDay,EMPTY_VALUE);
   ArrayInitialize(MinDay,EMPTY_VALUE);
   }
      
   MqlRates mtfRates[];
   
   ArraySetAsSeries(mtfRates,true);
   ArraySetAsSeries(Time    ,true); 
   ArraySetAsSeries(MaxDay  ,true); 
   ArraySetAsSeries(MinDay  ,true);
   
   copied = CopyRates(NULL,TimeFrame,0,NumberOfDays+2,mtfRates);
   
   if(copied < 0)
   {
   Print("not all Rates copied. Will try on next tick Error =",GetLastError(),", copied =",copied);
   return(0);
   }
   
   
   
//--- the main loop of calculations
   while(i <= NumberOfDays) 
   {
      if(currDay != TimeDay(Time[j])) 
      {
      open  = mtfRates[i+1].open;
      high  = mtfRates[i+1].high;
      low   = mtfRates[i+1].low;
      close = mtfRates[i+1].close;
      
      if(close <  open) price = (high + low + close + low  )/2;
      if(close >  open) price = (high + low + close + high )/2;
      if(close == open) price = (high + low + close + close)/2;
      
      i++;
      }
      
   currDay   = TimeDay(Time[j]);
   MaxDay[j] = price - low ;
   MinDay[j] = price - high;
   
   j++;
   }
   
   if(ShowTomorrow) 
   {
   open  = mtfRates[0].open;
   high  = mtfRates[0].high;
   low   = mtfRates[0].low;
   close = mtfRates[0].close;
     
   if(close <  open) price = (high + low + close + low  )/2;
   if(close >  open) price = (high + low + close + high )/2;
   if(close == open) price = (high + low + close + close)/2;
   
   ObjectMove(0,UniqueID+"linehi",0,Time[1],price - low );
   ObjectMove(0,UniqueID+"linelo",0,Time[1],price - high);
   
   ObjectSetInteger(0,UniqueID+"linehi",OBJPROP_TIME,0,Time[1]      ); ObjectSetDouble(0,UniqueID+"linehi",OBJPROP_PRICE,0,price - low);
   ObjectSetInteger(0,UniqueID+"linehi",OBJPROP_TIME,1,TimeCurrent()); ObjectSetDouble(0,UniqueID+"linehi",OBJPROP_PRICE,1,price - low);

   ObjectSetInteger(0,UniqueID+"linelo",OBJPROP_TIME,0,Time[1]      ); ObjectSetDouble(0,UniqueID+"linelo",OBJPROP_PRICE,0,price - high);
   ObjectSetInteger(0,UniqueID+"linelo",OBJPROP_TIME,1,TimeCurrent()); ObjectSetDouble(0,UniqueID+"linelo",OBJPROP_PRICE,1,price - high);
   }
//--- done
   return(rates_total);
}
//+------------------------------------------------------------------+
string timeframeToString(ENUM_TIMEFRAMES TF)
{
   switch(TF)
   {
   case PERIOD_CURRENT  : return("Current");
   case PERIOD_M1       : return("M1");   
   case PERIOD_M2       : return("M2");
   case PERIOD_M3       : return("M3");
   case PERIOD_M4       : return("M4");
   case PERIOD_M5       : return("M5");      
   case PERIOD_M6       : return("M6");
   case PERIOD_M10      : return("M10");
   case PERIOD_M12      : return("M12");
   case PERIOD_M15      : return("M15");
   case PERIOD_M20      : return("M20");
   case PERIOD_M30      : return("M30");
   case PERIOD_H1       : return("H1");
   case PERIOD_H2       : return("H2");
   case PERIOD_H3       : return("H3");
   case PERIOD_H4       : return("H4");
   case PERIOD_H6       : return("H6");
   case PERIOD_H8       : return("H8");
   case PERIOD_H12      : return("H12");
   case PERIOD_D1       : return("D1");
   case PERIOD_W1       : return("W1");
   case PERIOD_MN1      : return("MN1");      
   default              : return("Current");
   }
}

int TimeDay(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day);
}

int objCreate(string name,ENUM_OBJECT type,int style,int ray,int width,color clr)
{
   
   if(!ObjectCreate    (0,name,type,0,0,0,0,0,0,0)) return(-1);   
   if(!ObjectSetInteger(0,name,OBJPROP_STYLE,style)) return(-1);
   if(!ObjectSetInteger(0,name,OBJPROP_WIDTH,width)) return(-1);
   if(!ObjectSetInteger(0,name,OBJPROP_COLOR,clr)) return(-1); 
   if(ray > 0) 
      if(!ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,ray)) return(-1);
      
   return(1);
}

void deleteObj (string prefix)
{	
	string	name	= "";
	int		total	= ObjectsTotal(0) - 1;
	
	for(int i=total;i>=0;i--)
	{
	name = ObjectName(0,i);
	if(StringFind(name,prefix) >= 0) {ObjectDelete(0,name);}
	}
}
      
