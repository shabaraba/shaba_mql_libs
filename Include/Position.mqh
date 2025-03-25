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
//| ݸ�����                                            |
//+------------------------------------------------------------------+
class CPosition
{
private:
   string            m_positionId;        // ݸ���nX%P
   ulong             m_ticket;            // ����j�
   ulong             m_magic;             // ޸ï����
   double            m_volume;            // ��
   double            m_price;             // ��<
   double            m_stopLoss;          // ��<
   double            m_takeProfit;        // )ʺ��<
   bool              m_isOpen;            // ݸ���L����KK
   datetime          m_openTime;          // ���B�
   CTrade            m_trade;             // ��\�ָ���
   
public:
                     CPosition(string positionId = "");
                    ~CPosition() {};
   
   // ݸ�������\���
   void              UpdatePosition(ulong ticket, ulong magic, double price, double volume, double stopLoss, double takeProfit);
   bool              Close();
   bool              ModifyStopLoss(double stopLoss);
   bool              ModifyTakeProfit(double takeProfit);
   
   // �ÿ����
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
//| ���鯿                                                  |
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
//| ݸ����1n��                                             |
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
//| ݸ���n����                                            |
//+------------------------------------------------------------------+
bool CPosition::Close()
{
   if (!m_isOpen) return false;
   
   bool result = false;
   
   // ���X�
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
      // ݸ���L�k�X��fD�4
      m_isOpen = false;
      m_ticket = 0;
      m_volume = 0.0;
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| ��<n	�                                                |
//+------------------------------------------------------------------+
bool CPosition::ModifyStopLoss(double stopLoss)
{
   if (!m_isOpen) return false;
   
   bool result = false;
   
   // ݸ���x�Wf��<�	�
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
//| )ʺ��<n	�                                              |
//+------------------------------------------------------------------+
bool CPosition::ModifyTakeProfit(double takeProfit)
{
   if (!m_isOpen) return false;
   
   bool result = false;
   
   // ݸ���x�Wf)ʺ��<�	�
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
