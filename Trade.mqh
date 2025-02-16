#include <Object.mqh>
#include <Trade/Trade.mqh>
#include <Wrapper/Manager/lotSizeManager.mqh>

class WrappedTrade : public CObject {
private:
    LotSizeManagerInterface *lotSizeManager;
  CTrade trade;
  string symbol;
  ulong magicNumber;

public:
  WrappedTrade(string _symbol, ulong _magicNumber, LotSizeManagerInterface *_lotSizeManager) {
    symbol = _symbol;
    magicNumber = _magicNumber;
    trade = CTrade();
    trade.SetExpertMagicNumber(magicNumber);
    lotSizeManager = _lotSizeManager;
  }

  bool activeLong() { return activeLong(lotSizeManager.get(), 0, 0); }

  bool activeLong(const double lot) { return activeLong(lot, 0, 0); }

  bool activeLong(const double lot, const double sl, const double tp) {
    return trade.Buy(lot, symbol, 0, sl, tp, "Long");
  }

  bool activeShort() { return activeShort(lotSizeManager.get(), 0, 0); }

  bool activeShort(const double lot) { return activeShort(lot, 0, 0); }

  bool activeShort(const double lot, const double sl, const double tp) {
    return trade.Sell(lot, symbol, 0, sl, tp, "Short");
  }

  bool isPositionOpen() {
    for (int i = 0; i < PositionsTotal(); i++) {
      if (positionSelectByIndex(i)) {
        if (PositionGetInteger(POSITION_MAGIC) == magicNumber &&
            PositionGetString(POSITION_SYMBOL) == symbol)
          return true;
      }
    }
    return false;
  }

  bool isLongPositionOpen() {
    for (int i = 0; i < PositionsTotal(); i++) {
      if (positionSelectByIndex(i)) {
        if (PositionGetString(POSITION_SYMBOL) == symbol &&
            PositionGetInteger(POSITION_MAGIC) == magicNumber &&
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
          return true;
        }
      }
    }
    return false;
  }

  bool isShortPositionOpen() {
    for (int i = 0; i < PositionsTotal(); i++) {
      if (positionSelectByIndex(i)) {
        if (PositionGetString(POSITION_SYMBOL) == symbol &&
            PositionGetInteger(POSITION_MAGIC) == magicNumber &&
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
          return true;
        }
      }
    }
    return false;
  }

  void closeAll() {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (positionSelectByIndex(i)) {
        if (PositionGetInteger(POSITION_MAGIC) == magicNumber &&
            PositionGetString(POSITION_SYMBOL) == symbol) {
          ulong ticket = PositionGetInteger(POSITION_TICKET);
          trade.PositionClose(ticket);
        }
      }
    }
  }

  void closeLong() { closePosition(POSITION_TYPE_BUY); }

  void closeShort() { closePosition(POSITION_TYPE_SELL); }

  void closePosition(ENUM_POSITION_TYPE type) {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (positionSelectByIndex(i)) {
        if (PositionGetInteger(POSITION_MAGIC) == magicNumber &&
            PositionGetInteger(POSITION_TYPE) == type &&
            PositionGetString(POSITION_SYMBOL) == symbol) {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            trade.PositionClose(ticket);
          }
      }
    }
  }

  bool positionSelectByIndex(int index) {
    if (index < 0 || index >= PositionsTotal())
      return false;

    ulong ticket = PositionGetTicket(index);
    return PositionSelectByTicket(ticket);
  }

  void updateTrailingStop(double trailPips) {
    double stopLevel;
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double trailingDistance = trailPips * point * 10;

    for (int i = 0; i < PositionsTotal(); i++) {
      ulong ticket = PositionGetTicket(i);
      if (!PositionSelectByTicket(ticket))
        continue;

      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double stopLoss = PositionGetDouble(POSITION_SL);
      ENUM_POSITION_TYPE posType =
          (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if (posType == POSITION_TYPE_BUY) { // ロング（買いポジション）
        stopLevel = currentPrice - trailingDistance;
        if (stopLevel > stopLoss) {
          trade.PositionModify(ticket, stopLevel,
                               PositionGetDouble(POSITION_TP));
        }
      } else if (posType == POSITION_TYPE_SELL) { // ショート（売りポジション）
        stopLevel = currentPrice + trailingDistance;
        if (stopLevel < stopLoss) {
          trade.PositionModify(ticket, stopLevel,
                               PositionGetDouble(POSITION_TP));
        }
      }
    }
  }
};
