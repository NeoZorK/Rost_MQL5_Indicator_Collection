//+------------------------------------------------------------------+
//|                                                  TableSample.mq5 |
//|                                                 Marcin Konieczny |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Marcin Konieczny"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

#include <Table.mqh>
#include <PriceRow.mqh>
#include <PriceChangeRow.mqh>
#include <RSIRow.mqh>
#include <PriceMARow.mqh>

CTable *table; // ��������� �� ������ CTable
//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- ����������, ������� ����� �������������� � ������� (� ������ multi-timeframe mode)
   ENUM_TIMEFRAMES timeframes[4]={PERIOD_M1,PERIOD_H1,PERIOD_D1,PERIOD_W1};

//--- �������, ������� ����� �������������� � ������� (� ������ multi-currency mode)
   string symbols[4]={"EURUSD","GBPUSD","USDJPY","AUDCHF" };
//-- �������� ������� CTable
//   table = new CTable(timeframes); // ����� multi-timeframe mode
   table=new CTable(symbols); // ����� multi-currency mode

//--- ���������� ����� � �������
   table.AddRow(new CPriceRow());                 // ����������� ������� ����
   table.AddRow(new CPriceChangeRow(false));      // ����������� ��������� ���� �������� ����
   table.AddRow(new CPriceChangeRow(false,true)); // ����������� ��������� ���� �������� ���� (� ���������)
   table.AddRow(new CPriceChangeRow(true));       // ����������� ��������� ���� � ���� �������
   table.AddRow(new CRSIRow(14));                 // ����������� �������� RSI(14)
   table.AddRow(new CRSIRow(10));                 // ����������� �������� RSI(10)
   table.AddRow(new CPriceMARow(MODE_SMA,20,0));  // ����������� ���������� ������� SMA(20) > ������� ����

//--- ��������� ���������� �������
   table.SetFont("Arial",10,clrYellow);  // �����, ������, ����
   table.SetCellSize(60, 20);            // ������ � ������
   table.SetDistance(10, 10);            // ���������� �� �������� ������� ���� �������

   table.Update(); // �������������� ���������� (�����������) �������

   return(0);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- �������� ���������� table � ����������� ������
   delete(table);
  }
//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- ���������� �������: ���������� � �����������
   table.Update();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ���������� ������� OnChartEvent                                  |
//| ������������ ������� CHARTEVENT_CUSTOM,������������ ������������ |
//| SpyAgent (��������� ������ ��� ������ multi-currency mode)       |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   table.Update(); // ���������� �������: ���������� � �����������
  }
//+------------------------------------------------------------------+

