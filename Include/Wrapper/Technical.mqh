//+------------------------------------------------------------------+
//|                                                   Technical.mqh |
//|                                      Copyright 2025, Your Name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Ư˫�h���Ȣpn������                     |
//+------------------------------------------------------------------+
class CTechnical
{
public:
   // ��n �$�֗
   static double iHighest(int period, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT, string symbol = NULL)
   {
      if (symbol == NULL) symbol = _Symbol;
      
      double highest = 0;
      for (int i = 0; i < period; i++)
      {
         double high = iHigh(symbol, timeframe, i);
         if (i == 0 || high > highest)
            highest = high;
      }
      
      return highest;
   }
   
   // ��n �$�֗
   static double iLowest(int period, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT, string symbol = NULL)
   {
      if (symbol == NULL) symbol = _Symbol;
      
      double lowest = 0;
      for (int i = 0; i < period; i++)
      {
         double low = iLow(symbol, timeframe, i);
         if (i == 0 || low < lowest)
            lowest = low;
      }
      
      return lowest;
   }
   
   // ATR$�֗
   static double iATR(int period, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT, string symbol = NULL)
   {
      if (symbol == NULL) symbol = _Symbol;
      
      int handle = iATR(symbol, timeframe, period);
      if (handle == INVALID_HANDLE)
      {
         Print("iATRn����\k1WW~W_������=", GetLastError());
         return 0.0;
      }
      
      double atrBuffer[];
      ArraySetAsSeries(atrBuffer, true);
      
      int copied = CopyBuffer(handle, 0, 0, 1, atrBuffer);
      if (copied <= 0)
      {
         Print("ATR$n���k1WW~W_������=", GetLastError());
         IndicatorRelease(handle);
         return 0.0;
      }
      
      double atr = atrBuffer[0];
      IndicatorRelease(handle);
      
      return atr;
   }
};
