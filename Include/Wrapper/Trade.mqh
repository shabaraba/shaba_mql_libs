#include "../Manager/ExitLevel/ExitLevelManagerInterface.mqh"
#include "../Manager/LotSize/LotSizeManagerInterface.mqh"
#include <Object.mqh>
#include <Trade/Trade.mqh>

class WrappedTrade : public CObject {
private:
  LotSizeManager *lotSizeManager;
  ExitLevelManager *exitLevelManager;
  CTrade trade;
  string symbol;
  ulong magicNumber;
  int digits;

public:
  WrappedTrade(string _symbol, ulong _magicNumber,
               LotSizeManager *_lotSizeManager,
               ExitLevelManager *_exitLevelManager) {
    symbol = _symbol;
    magicNumber = _magicNumber;
    trade = CTrade();
    trade.SetExpertMagicNumber(magicNumber);
    lotSizeManager = _lotSizeManager;
    exitLevelManager = _exitLevelManager;
    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
  }

  uint getErrorCode() { return trade.ResultRetcode(); }

  bool limitLong(double price) {
    bool ret = trade.OrderOpen(
        symbol, ORDER_TYPE_BUY_LIMIT, lotSizeManager.get(),
        NormalizeDouble(price, digits), NormalizeDouble(price, digits),
        NormalizeDouble(exitLevelManager.getSl(price, POSITION_TYPE_BUY),
                        digits),
        NormalizeDouble(exitLevelManager.getTp(price, POSITION_TYPE_BUY),
                        digits),
        ORDER_TIME_GTC, 0, "");

    if (ret) { // OrderSend の返り値 && エラーを確認する
      int error = GetLastError();
      printf("OrderSend Error : %d", error);
      printf("current bid: %f", SymbolInfoDouble(Symbol(), SYMBOL_BID));
    }
    return ret;
  }

  bool stopLong(double price) {
    // bool ret = trade.OrderSend(request, result);
    bool ret = trade.OrderOpen(
        symbol, ORDER_TYPE_BUY_STOP, lotSizeManager.get(),
        NormalizeDouble(price, digits), NormalizeDouble(price, digits),
        NormalizeDouble(exitLevelManager.getSl(price, POSITION_TYPE_BUY),
                        digits),
        NormalizeDouble(exitLevelManager.getTp(price, POSITION_TYPE_BUY),
                        digits),
        ORDER_TIME_GTC, 0, "");

    if (ret) { // OrderSend の返り値 && エラーを確認する
      int error = GetLastError();
      printf("OrderSend Error : %d", error);
      printf("current bid: %f", SymbolInfoDouble(Symbol(), SYMBOL_BID));
    }
    return ret;
  }

  bool limitShort(double price) {
    bool ret = trade.OrderOpen(
        symbol, ORDER_TYPE_SELL_LIMIT, lotSizeManager.get(),
        NormalizeDouble(price, digits), NormalizeDouble(price, digits),
        NormalizeDouble(exitLevelManager.getSl(price, POSITION_TYPE_SELL),
                        digits),
        NormalizeDouble(exitLevelManager.getTp(price, POSITION_TYPE_SELL),
                        digits),
        ORDER_TIME_GTC, 0, "");

    if (ret) { // OrderSend の返り値 && エラーを確認する
      int error = GetLastError();
      printf("OrderSend Error : %d", error);
      printf("current bid: %f", SymbolInfoDouble(Symbol(), SYMBOL_BID));
    }

    return ret;
  }

  bool stopShort(double price) {
    // bool ret = trade.OrderSend(request, result);
    bool ret = trade.OrderOpen(
        symbol, ORDER_TYPE_SELL_STOP, lotSizeManager.get(),
        NormalizeDouble(price, digits), NormalizeDouble(price, digits),
        NormalizeDouble(exitLevelManager.getSl(price, POSITION_TYPE_SELL),
                        digits),
        NormalizeDouble(exitLevelManager.getTp(price, POSITION_TYPE_SELL),
                        digits),
        ORDER_TIME_GTC, 0, "");

    if (ret) { // OrderSend の返り値 && エラーを確認する
      int error = GetLastError();
      printf("OrderSend Error : %d", error);
      printf("current bid: %f", SymbolInfoDouble(Symbol(), SYMBOL_BID));
    }

    return ret;
  }

  bool activeLong() {
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    return activeLong(lotSizeManager.get(),
                      exitLevelManager.getSl(bid, POSITION_TYPE_BUY),
                      exitLevelManager.getTp(bid, POSITION_TYPE_BUY));
  }

  bool activeLong(const double lot) {
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    return activeLong(lot, exitLevelManager.getSl(bid, POSITION_TYPE_BUY),
                      exitLevelManager.getTp(bid, POSITION_TYPE_BUY));
  }

  bool activeLong(const double lot, const double sl, const double tp) {
    return trade.Buy(lot, symbol, 0, sl, tp, "Long");
  }

  bool activeShort() {
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    return activeShort(lotSizeManager.get(),
                       exitLevelManager.getSl(ask, POSITION_TYPE_SELL),
                       exitLevelManager.getTp(ask, POSITION_TYPE_SELL));
  }

  bool activeShort(const double lot) {
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    return activeShort(lot, exitLevelManager.getSl(ask, POSITION_TYPE_SELL),
                       exitLevelManager.getTp(ask, POSITION_TYPE_SELL));
  }

  bool activeShort(const double lot, const double sl, const double tp) {
    return trade.Sell(lot, symbol, 0, sl, tp, "Short");
  }

  bool hasOpenPosition() {
    for (int i = 0; i < PositionsTotal(); i++) {
      if (positionSelectByIndex(i)) {
        if (PositionGetInteger(POSITION_MAGIC) == magicNumber &&
            PositionGetString(POSITION_SYMBOL) == symbol)
          return true;
      }
    }
    return false;
  }

  bool hasLongPosition() {
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

  bool hasShortPosition() {
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

  bool hasPendingLimitOrder() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        // 指値注文または逆指値注文かつ Magic Number が一致
        if ((type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT ||
             type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP) &&
            magic == magicNumber) {
          return true;
        }
      }
    }
    return false; // 指値注文なし
  }

  void deleteLimitAll() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        // 指値注文または逆指値注文かつ Magic Number が一致
        if ((type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT) &&
            magic == magicNumber) {
          trade.OrderDelete(ticket);
        }
      }
    }
  }

  void deleteStopAll() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        // 指値注文または逆指値注文かつ Magic Number が一致
        if ((type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP) &&
            magic == magicNumber) {
          trade.OrderDelete(ticket);
        }
      }
    }
  }

  void deleteStopLongAll() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        // 指値注文または逆指値注文かつ Magic Number が一致
        if (type == ORDER_TYPE_BUY_STOP && magic == magicNumber) {
          trade.OrderDelete(ticket);
        }
      }
    }
  }

  void deleteStopShortAll() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        // 指値注文または逆指値注文かつ Magic Number が一致
        if (type == ORDER_TYPE_SELL_STOP && magic == magicNumber) {
          trade.OrderDelete(ticket);
        }
      }
    }
  }

  void deleteOrderAll() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        // 指値注文または逆指値注文かつ Magic Number が一致
        if (magic == magicNumber) {
          trade.OrderDelete(ticket);
        }
      }
    }
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

  void updateAllOrder() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ENUM_POSITION_TYPE positionType;
        if (type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_LIMIT) {
          positionType = POSITION_TYPE_BUY;
        } else {
          positionType = POSITION_TYPE_BUY;
        }
        // 指値注文または逆指値注文かつ Magic Number が一致
        if (magic == magicNumber) {
          double price = OrderGetDouble(ORDER_PRICE_OPEN);
          OrderModify(ticket, lotSizeManager.get(), price,
                      exitLevelManager.getSl(price, positionType),
                      exitLevelManager.getTp(price, positionType),
                      ORDER_TIME_GTC, 0, OrderGetDouble(ORDER_PRICE_OPEN));
        }
      }
    }
  }

  bool OrderModify(const ulong ticket, const double volume, const double price,
                   const double sl, const double tp,
                   const ENUM_ORDER_TYPE_TIME type_time,
                   const datetime expiration, const double stoplimit) {
    if (!OrderSelect(ticket))
      return (false);

    MqlTradeRequest m_request; // request data
    MqlTradeResult m_result;   // result data
    //--- setting request
    m_request.symbol = OrderGetString(ORDER_SYMBOL);
    m_request.action = TRADE_ACTION_MODIFY;
    m_request.magic = magicNumber;
    m_request.order = ticket;
    m_request.volume = volume;
    m_request.price = price;
    m_request.stoplimit = stoplimit;
    m_request.sl = sl;
    m_request.tp = tp;
    m_request.type_time = type_time;
    m_request.expiration = expiration;
    //--- action and return the result
    return (trade.OrderSend(m_request, m_result));
  }
};
