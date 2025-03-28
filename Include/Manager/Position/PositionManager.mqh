//+------------------------------------------------------------------+
//|                                             PositionManager.mqh |
//|                                       Copyright 2025, Your Name |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "PositionManagerInterface.mqh"
#include "../../Position.mqh"
#include <Arrays/ArrayObj.mqh>

//+------------------------------------------------------------------+
//| ݸ�����                                            |
//+------------------------------------------------------------------+
class CPositionManager : public CObject
{
private:
   CArrayObj          m_positions;        // ݸ���ָ���nM
   
   // y�nݸ���ID�dݸ���ָ���n���ï��֗
   int                FindPositionIndex(string positionId);
   
public:
                     CPositionManager();
                    ~CPositionManager();
   
   // ݸ���n���֗��
   CPosition*         AddPosition(string positionId);
   CPosition*         GetPosition(string positionId);
   void               UpdatePositions();
   int                GetPositionsCount() const { return m_positions.Total(); }
   
   // ݸ���n ��\
   void               CloseAllPositions();
};

//+------------------------------------------------------------------+
//| ���鯿                                                  |
//+------------------------------------------------------------------+
CPositionManager::CPositionManager()
{
   m_positions.FreeMode(false);  // ML�ָ��Ȓ��g�>WjD���
}

//+------------------------------------------------------------------+
//| ǹ�鯿                                                    |
//+------------------------------------------------------------------+
CPositionManager::~CPositionManager()
{
   // ݸ���ָ���n����>
   for (int i = 0; i < m_positions.Total(); i++)
   {
      CPosition *pos = m_positions.At(i);
      if (pos != NULL)
         delete pos;
   }
   
   m_positions.Clear();
}

//+------------------------------------------------------------------+
//| �WDݸ���ָ��Ȓ��                               |
//+------------------------------------------------------------------+
CPosition* CPositionManager::AddPosition(string positionId)
{
   // �kXIDnݸ���LX(Y�K��
   CPosition *existingPos = GetPosition(positionId);
   if (existingPos != NULL)
      return existingPos;
   
   // �WDݸ���ָ��Ȓ\WfMk��
   CPosition *newPos = new CPosition(positionId);
   if (newPos != NULL)
   {
      m_positions.Add(newPos);
   }
   
   return newPos;
}

//+------------------------------------------------------------------+
//| �W_IDnݸ���ָ��Ȓ֗                        |
//+------------------------------------------------------------------+
CPosition* CPositionManager::GetPosition(string positionId)
{
   int index = FindPositionIndex(positionId);
   
   if (index >= 0)
      return m_positions.At(index);
   
   // X(WjD4o��\
   return AddPosition(positionId);
}

//+------------------------------------------------------------------+
//| y�nݸ���ID�dݸ���ָ���n���ï��֗ |
//+------------------------------------------------------------------+
int CPositionManager::FindPositionIndex(string positionId)
{
   for (int i = 0; i < m_positions.Total(); i++)
   {
      CPosition *pos = m_positions.At(i);
      if (pos != NULL && pos.GetPositionId() == positionId)
         return i;
   }
   
   return -1;  // �dK�jD4
}

//+------------------------------------------------------------------+
//| Yyfnݸ���n�K���                                   |
//+------------------------------------------------------------------+
void CPositionManager::UpdatePositions()
{
   // MQL5nݸ����1�Ck�WfD�ݸ���n�K���
   for (int i = 0; i < m_positions.Total(); i++)
   {
      CPosition *pos = m_positions.At(i);
      if (pos != NULL && pos.IsOpen())
      {
         // ����j�gݸ���Y
         ulong ticket = pos.GetTicket();
         if (ticket > 0 && !PositionSelectByTicket(ticket))
         {
            // ݸ���LX(WjOjc_4�X��_4	
            pos.Close();  // ��K�����k��
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Yyfn����ݸ������                            |
//+------------------------------------------------------------------+
void CPositionManager::CloseAllPositions()
{
   for (int i = 0; i < m_positions.Total(); i++)
   {
      CPosition *pos = m_positions.At(i);
      if (pos != NULL && pos.IsOpen())
      {
         pos.Close();
      }
   }
}
