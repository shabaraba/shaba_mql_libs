//+------------------------------------------------------------------+
//|                                         FixedLotSizeManager.mqh |
//|                                       Copyright 2025, Your Name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "LotSizeManagerInterface.mqh"

//+------------------------------------------------------------------+
//| 固定ロットサイズ管理クラス                                       |
//+------------------------------------------------------------------+
class CFixedLotSizeManager
{
private:
   double            m_lotSize;           // 固定ロットサイズ
   
public:
                     CFixedLotSizeManager();
                    ~CFixedLotSizeManager() {};
   
   // ロットサイズの設定・取得
   void              SetLot(double lotSize) { m_lotSize = lotSize; }
   double            CalculateLotSize() { return m_lotSize; }
};

//+------------------------------------------------------------------+
//| コンストラクタ                                                  |
//+------------------------------------------------------------------+
CFixedLotSizeManager::CFixedLotSizeManager()
{
   m_lotSize = 0.1;  // デフォルトロットサイズ
}
