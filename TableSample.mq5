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

CTable *table; // указатель на объект CTable
//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- таймфреймы, которые будут использоваться в таблице (в режиме multi-timeframe mode)
   ENUM_TIMEFRAMES timeframes[4]={PERIOD_M1,PERIOD_H1,PERIOD_D1,PERIOD_W1};

//--- символы, которые будут использоваться в таблице (в режиме multi-currency mode)
   string symbols[4]={"EURUSD","GBPUSD","USDJPY","AUDCHF" };
//-- создание объекта CTable
//   table = new CTable(timeframes); // режим multi-timeframe mode
   table=new CTable(symbols); // режим multi-currency mode

//--- добавление строк в таблицу
   table.AddRow(new CPriceRow());                 // отображение текущую цену
   table.AddRow(new CPriceChangeRow(false));      // отображение изменения цены текущего бара
   table.AddRow(new CPriceChangeRow(false,true)); // отображение изменения цены текущего бара (в процентах)
   table.AddRow(new CPriceChangeRow(true));       // отображение изменения цены в виде стрелок
   table.AddRow(new CRSIRow(14));                 // отображение значения RSI(14)
   table.AddRow(new CRSIRow(10));                 // отображение значения RSI(10)
   table.AddRow(new CPriceMARow(MODE_SMA,20,0));  // отображение выполнения условия SMA(20) > текущей цены

//--- установка параметров таблицы
   table.SetFont("Arial",10,clrYellow);  // шрифт, размер, цвет
   table.SetCellSize(60, 20);            // ширина и высота
   table.SetDistance(10, 10);            // расстояние от верхнего правого угла графика

   table.Update(); // принудительное обновление (перерисовка) таблицы

   return(0);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- вызываем деструктор table и освобождаем память
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
//--- обновление таблицы: перерасчет и перерисовка
   table.Update();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Обработчик события OnChartEvent                                  |
//| Обрабатывает событие CHARTEVENT_CUSTOM,отправленное индикаторами |
//| SpyAgent (требуется только для режима multi-currency mode)       |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   table.Update(); // обновление таблицы: перерасчет и перерисовка
  }
//+------------------------------------------------------------------+

