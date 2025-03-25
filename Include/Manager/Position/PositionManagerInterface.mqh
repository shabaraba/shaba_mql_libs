//+------------------------------------------------------------------+
//|                                     PositionManagerInterface.mqh |
//|                                       Copyright 2025, Your Name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| ポジション管理のインターフェース                                 |
//+------------------------------------------------------------------+
class IPositionManager
{
public:
   // 純粋仮想関数
   virtual void       UpdatePositions() = 0;
   virtual void       CloseAllPositions() = 0;
};
