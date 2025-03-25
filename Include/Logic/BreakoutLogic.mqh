//+------------------------------------------------------------------+
//|                                               BreakoutLogic.mqh |
//|                                       Copyright 2025, Your Name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "LogicInterface.mqh"
#include "../Wrapper/Technical.mqh"

//+------------------------------------------------------------------+
//| ブレイクアウト戦略ロジック                                      |
//+------------------------------------------------------------------+
class CBreakoutLogic
{
private:
   int               m_highPeriod;        // 高値参照期間
   int               m_lowPeriod;         // 安値参照期間
   bool              m_useWeekly;         // 週足を使用するかどうか
   ENUM_TIMEFRAMES   m_timeframe;         // タイムフレーム
   int               m_atrPeriod;         // ATR計算期間
   double            m_atrMultiplier;     // ATR乗数
   
   double            CalculateStopLoss(double entryPrice, bool isLong);
   
public:
                     CBreakoutLogic(int highPeriod, int lowPeriod, bool useWeekly, 
                                   ENUM_TIMEFRAMES timeframe, int atrPeriod, double atrMultiplier);
                    ~CBreakoutLogic() {};
   
   // 各種判定メソッド
   bool              IsLongEntry(bool isNewBar);
   bool              IsShortEntry(bool isNewBar);
   bool              IsLongExit(bool isNewBar);
   bool              IsShortExit(bool isNewBar);
   double            GetLongStopLoss(double entryPrice);
   double            GetShortStopLoss(double entryPrice);
};

//+------------------------------------------------------------------+
//| コンストラクタ                                                  |
//+------------------------------------------------------------------+
CBreakoutLogic::CBreakoutLogic(int highPeriod, int lowPeriod, bool useWeekly, 
                              ENUM_TIMEFRAMES timeframe, int atrPeriod, double atrMultiplier)
{
   m_highPeriod = highPeriod;
   m_lowPeriod = lowPeriod;
   m_useWeekly = useWeekly;
   m_timeframe = timeframe;
   m_atrPeriod = atrPeriod;
   m_atrMultiplier = atrMultiplier;
}

//+------------------------------------------------------------------+
//| ロング（買い）エントリー条件                                     |
//+------------------------------------------------------------------+
bool CBreakoutLogic::IsLongEntry(bool isNewBar)
{
   if (!isNewBar) return false;  // 新しいバーの場合のみ判定
   
   ENUM_TIMEFRAMES periodTF = m_useWeekly ? PERIOD_W1 : m_timeframe;
   double highest = CTechnical::iHighest(m_highPeriod, periodTF);
   
   // 現在の価格が期間内の最高値を上回ったらエントリー
   return iClose(_Symbol, m_timeframe, 0) > highest && iClose(_Symbol, m_timeframe, 1) <= highest;
}

//+------------------------------------------------------------------+
//| ショート（売り）エントリー条件                                   |
//+------------------------------------------------------------------+
bool CBreakoutLogic::IsShortEntry(bool isNewBar)
{
   if (!isNewBar) return false;  // 新しいバーの場合のみ判定
   
   ENUM_TIMEFRAMES periodTF = m_useWeekly ? PERIOD_W1 : m_timeframe;
   double lowest = CTechnical::iLowest(m_lowPeriod, periodTF);
   
   // 現在の価格が期間内の最安値を下回ったらエントリー
   return iClose(_Symbol, m_timeframe, 0) < lowest && iClose(_Symbol, m_timeframe, 1) >= lowest;
}

//+------------------------------------------------------------------+
//| ロング（買い）イグジット条件                                     |
//+------------------------------------------------------------------+
bool CBreakoutLogic::IsLongExit(bool isNewBar)
{
   if (!isNewBar) return false;  // 新しいバーの場合のみ判定
   
   ENUM_TIMEFRAMES periodTF = m_useWeekly ? PERIOD_W1 : m_timeframe;
   double lowest = CTechnical::iLowest(m_lowPeriod, periodTF);
   
   // 現在の価格が期間内の最安値を下回ったらイグジット
   return iClose(_Symbol, m_timeframe, 0) < lowest && iClose(_Symbol, m_timeframe, 1) >= lowest;
}

//+------------------------------------------------------------------+
//| ショート（売り）イグジット条件                                   |
//+------------------------------------------------------------------+
bool CBreakoutLogic::IsShortExit(bool isNewBar)
{
   if (!isNewBar) return false;  // 新しいバーの場合のみ判定
   
   ENUM_TIMEFRAMES periodTF = m_useWeekly ? PERIOD_W1 : m_timeframe;
   double highest = CTechnical::iHighest(m_highPeriod, periodTF);
   
   // 現在の価格が期間内の最高値を上回ったらイグジット
   return iClose(_Symbol, m_timeframe, 0) > highest && iClose(_Symbol, m_timeframe, 1) <= highest;
}

//+------------------------------------------------------------------+
//| 損切り価格の計算（内部メソッド）                                 |
//+------------------------------------------------------------------+
double CBreakoutLogic::CalculateStopLoss(double entryPrice, bool isLong)
{
   double atr = CTechnical::iATR(m_atrPeriod, m_timeframe);
   double stopDistance = atr * m_atrMultiplier;
   
   return isLong ? entryPrice - stopDistance : entryPrice + stopDistance;
}

//+------------------------------------------------------------------+
//| ロング（買い）の損切り水準                                      |
//+------------------------------------------------------------------+
double CBreakoutLogic::GetLongStopLoss(double entryPrice)
{
   return CalculateStopLoss(entryPrice, true);
}

//+------------------------------------------------------------------+
//| ショート（売り）の損切り水準                                    |
//+------------------------------------------------------------------+
double CBreakoutLogic::GetShortStopLoss(double entryPrice)
{
   return CalculateStopLoss(entryPrice, false);
}
