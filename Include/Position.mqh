//+------------------------------------------------------------------+
//|                                                    Position.mqh |
//|                                       Copyright 2025, Your Name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Ý¸·çó¡¯é¹                                            |
//+------------------------------------------------------------------+
class CPosition
{
private:
   string            m_positionId;        // Ý¸·çónX%P
   ulong             m_ticket;            // Á±ÃÈj÷
   ulong             m_magic;             // Þ¸Ã¯ÊóÐü
   double            m_volume;            // ÖÏ
   double            m_price;             // Ö¡<
   double            m_stopLoss;          // Š¡<
   double            m_takeProfit;        // )Êºš¡<
   bool              m_isOpen;            // Ý¸·çóLªü×ó¶KK
   datetime          m_openTime;          // Ö‹ËB“
   CTrade            m_trade;             // ÖÍ\ªÖ¸§¯È
   
public:
                     CPosition(string positionId = "");
                    ~CPosition() {};
   
   // Ý¸·çóô°ûÍ\á½ÃÉ
   void              UpdatePosition(ulong ticket, ulong magic, double price, double volume, double stopLoss, double takeProfit);
   bool              Close();
   bool              ModifyStopLoss(double stopLoss);
   bool              ModifyTakeProfit(double takeProfit);
   
   // ²Ã¿üá½ÃÉ
   string            GetPositionId() const { return m_positionId; }
   ulong             GetTicket() const { return m_ticket; }
   double            GetVolume() const { return m_volume; }
   double            GetPrice() const { return m_price; }
   double            GetStopLoss() const { return m_stopLoss; }
   double            GetTakeProfit() const { return m_takeProfit; }
   bool              IsOpen() const { return m_isOpen; }
   datetime          GetOpenTime() const { return m_openTime; }
};

//+------------------------------------------------------------------+
//| ³ó¹Èé¯¿                                                  |
//+------------------------------------------------------------------+
CPosition::CPosition(string positionId)
{
   m_positionId = positionId;
   m_isOpen = false;
   m_ticket = 0;
   m_magic = 0;
   m_volume = 0.0;
   m_price = 0.0;
   m_stopLoss = 0.0;
   m_takeProfit = 0.0;
   m_openTime = 0;
}

//+------------------------------------------------------------------+
//| Ý¸·çóÅ1nô°                                             |
//+------------------------------------------------------------------+
void CPosition::UpdatePosition(ulong ticket, ulong magic, double price, double volume, double stopLoss, double takeProfit)
{
   m_ticket = ticket;
   m_magic = magic;
   m_price = price;
   m_volume = volume;
   m_stopLoss = stopLoss;
   m_takeProfit = takeProfit;
   m_isOpen = true;
   m_openTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Ý¸·çón¯íüº                                            |
//+------------------------------------------------------------------+
bool CPosition::Close()
{
   if (!m_isOpen) return false;
   
   bool result = false;
   
   // Ö’‰X‹
   if (PositionSelectByTicket(m_ticket))
   {
      result = m_trade.PositionClose(m_ticket);
      if (result)
      {
         m_isOpen = false;
         m_ticket = 0;
         m_volume = 0.0;
      }
   }
   else
   {
      // Ý¸·çóLâk‰X‰ŒfD‹4
      m_isOpen = false;
      m_ticket = 0;
      m_volume = 0.0;
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Š¡<n	ô                                                |
//+------------------------------------------------------------------+
bool CPosition::ModifyStopLoss(double stopLoss)
{
   if (!m_isOpen) return false;
   
   bool result = false;
   
   // Ý¸·çó’xžWfŠ¡<’	ô
   if (PositionSelectByTicket(m_ticket))
   {
      result = m_trade.PositionModify(m_ticket, stopLoss, m_takeProfit);
      if (result)
      {
         m_stopLoss = stopLoss;
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| )Êºš¡<n	ô                                              |
//+------------------------------------------------------------------+
bool CPosition::ModifyTakeProfit(double takeProfit)
{
   if (!m_isOpen) return false;
   
   bool result = false;
   
   // Ý¸·çó’xžWf)Êºš¡<’	ô
   if (PositionSelectByTicket(m_ticket))
   {
      result = m_trade.PositionModify(m_ticket, m_stopLoss, takeProfit);
      if (result)
      {
         m_takeProfit = takeProfit;
      }
   }
   
   return result;
}
