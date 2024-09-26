//+------------------------------------------------------------------+
//|                                                   VDirection.mq5 |
//|                                    Copyright 2012, 2012, victorg |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2012, victorg."
#property link        "http://www.mql5.com"
#property version     "1.01"
#property description "Direction indicator. Multi-'Williams Percent Range'."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//--- input parameters
input int TMode=1;               // Mode: 0 - fast, 1 - normal, 2 - slow
input int InpXCoord=35;          // X Coordinate
input int InpYCoord=0;           // Y Coordinate
//--- global variables
int    XCoord,YCoord,T1,T2,T3,T4,T5;
string ShortName;
color  IndColor[64];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check for input values
   T1=12; T2=15; T3=20; T4=30; T5=60;
   if(TMode==0){T1=6; T2=8; T3=10; T4=15; T5=30;}
   if(TMode==2){T1=24; T2=30; T3=40; T4=60; T5=120;}
   XCoord=InpXCoord;
   YCoord=InpYCoord;
//--- set shortname
// ShortName="VDir";
   ShortName="VDir"+string(TMode)+_Symbol;
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);

//---          
   initGraph();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int i;
   string nam;

   for(i=0;i<=184;i++)
     {
      nam=ShortName+(string)i;
      ObjectDelete(0,nam);
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int i;
   double min,max,chan,v,val[5];

   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

   min=Low[0]; max=High[0];
   for(i=1;i<T5;i++)
     {
      if(i==T1)
        {
         chan=(max-min)/2.0; v=Close[0]-(max+min)/2.0;
         if(chan==0)val[0]=0.0;
         else val[0]=v/chan;
        }
      if(i==T2)
        {
         chan=(max-min)/2.0; v=Close[0]-(max+min)/2.0;
         if(chan==0)val[1]=0.0;
         else val[1]=v/chan;
        }
      if(i==T3)
        {
         chan=(max-min)/2.0; v=Close[0]-(max+min)/2.0;
         if(chan==0)val[2]=0.0;
         else val[2]=v/chan;
        }
      if(i==T4)
        {
         chan=(max-min)/2.0; v=Close[0]-(max+min)/2.0;
         if(chan==0)val[3]=0.0;
         else val[3]=v/chan;
        }
      if(Low[i]<min)min=Low[i];
      if(High[i]>max)max=High[i];
     }
   chan=(max-min)/2.0; v=Close[0]-(max+min)/2.0;
   if(chan==0)val[4]=0.0;
   else val[4]=v/chan;

   drawGraph(val);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| drawGraph                                                        |
//+------------------------------------------------------------------+
void drawGraph(double &val[])
  {
   int i,j,p,c;
   string nam;

   for(j=0;j<5;j++)
     {
      p=(int)(11.1*val[4-j])+11;
      for(i=0;i<23;i++)
        {
         c=i+23;
         if(i<=p && i>11)c=i;
         if(i>=p && i<11)c=i;
         nam=ShortName+(string)(i+j*23);
         ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[c]);
        }
     }
  }
//+------------------------------------------------------------------+
//| initGraph                                                        |
//+------------------------------------------------------------------+
void initGraph()
  {
   int i,j,k;
   string nam;

   IndColor[0]=C'255,7,7';
   IndColor[1]=C'250,255,7';
   IndColor[2]=C'225,255,7';
   IndColor[3]=C'200,255,7';
   IndColor[4]=C'175,255,7';
   IndColor[5]=C'150,255,7';
   IndColor[6]=C'125,255,7';
   IndColor[7]=C'100,255,7';
   IndColor[8]=C'75,255,7';
   IndColor[9]=C'50,255,7';
   IndColor[10]=C'25,255,7';
   IndColor[11]=C'130,130,24';
   IndColor[12]=C'25,255,7';
   IndColor[13]=C'50,255,7';
   IndColor[14]=C'75,255,7';
   IndColor[15]=C'100,255,7';
   IndColor[16]=C'125,255,7';
   IndColor[17]=C'150,255,7';
   IndColor[18]=C'175,255,7';
   IndColor[19]=C'200,255,7';
   IndColor[20]=C'225,255,7';
   IndColor[21]=C'250,255,7';
   IndColor[22]=C'255,7,7';
   IndColor[23]=C'56,24,24';
   IndColor[24]=C'30,45,45';
   IndColor[25]=C'30,45,45';
   IndColor[26]=C'30,45,45';
   IndColor[27]=C'30,45,45';
   IndColor[28]=C'30,45,45';
   IndColor[29]=C'30,45,45';
   IndColor[30]=C'30,45,45';
   IndColor[31]=C'30,45,45';
   IndColor[32]=C'30,45,45';
   IndColor[33]=C'30,45,45';
   IndColor[34]=C'130,130,24';
   IndColor[35]=C'30,45,45';
   IndColor[36]=C'30,45,45';
   IndColor[37]=C'30,45,45';
   IndColor[38]=C'30,45,45';
   IndColor[39]=C'30,45,45';
   IndColor[40]=C'30,45,45';
   IndColor[41]=C'30,45,45';
   IndColor[42]=C'30,45,45';
   IndColor[43]=C'30,45,45';
   IndColor[44]=C'30,45,45';
   IndColor[45]=C'56,24,24';
   IndColor[62]=C'54,54,10';
   IndColor[63]=C'130,130,24';

   for(i=0;i<23;i++)
     {
      for(j=0;j<5;j++)
        {
         nam=ShortName+(string)(i+j*23);
         ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
         ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,31);
         ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+j*13);
         ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+i*4);
         ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[i+23]);
         ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
         ObjectSetString(0,nam,OBJPROP_TEXT,"-");
        }
     }
   nam=ShortName+(string)115;
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+67);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+18);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"-");
   nam=ShortName+(string)116;
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+67);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+58);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"-");
   nam=ShortName+(string)117;
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+67);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+98);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"-");
   nam=ShortName+(string)118;
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-14);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+18);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"1 -");
   nam=ShortName+(string)119;
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-14);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+58);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"0 -");
   nam=ShortName+(string)120;
   ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-14);
   ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+98);
   ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[63]);
   ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
   ObjectSetString(0,nam,OBJPROP_TEXT,"1 -");
   for(i=121,j=0;i<=125;i++,j++)
     {
      nam=ShortName+(string)i;
      ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+j*13);
      ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+13);
      ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[62]);
      ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
      ObjectSetString(0,nam,OBJPROP_TEXT,"__");
     }
   for(i=126,j=0;i<=130;i++,j++)
     {
      nam=ShortName+(string)i;
      ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord+j*13);
      ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+111);
      ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[62]);
      ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
      ObjectSetString(0,nam,OBJPROP_TEXT,"__");
     }
   k=131;
   for(i=0;i<9;i++)
     {
      for(j=0;j<6;j++)
        {
         nam=ShortName+(string)(k+i+j*9);
         ObjectCreate(0,nam,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,nam,OBJPROP_CORNER,CORNER_LEFT_LOWER);
         ObjectSetInteger(0,nam,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0,nam,OBJPROP_FONTSIZE,9);
         ObjectSetInteger(0,nam,OBJPROP_XDISTANCE,XCoord-1+j*13);
         ObjectSetInteger(0,nam,OBJPROP_YDISTANCE,YCoord+13+i*11);
         ObjectSetInteger(0,nam,OBJPROP_COLOR,IndColor[62]);
         ObjectSetString(0,nam,OBJPROP_FONT,"Arial");
         ObjectSetString(0,nam,OBJPROP_TEXT,"|");
        }
     }
  }
//+------------------------------------------------------------------+
