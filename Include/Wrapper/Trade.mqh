#include "../Manager/ExitLevel/ExitLevelManagerInterface.mqh"
#include "../Manager/LotSize/LotSizeManagerInterface.mqh"
#include <Object.mqh>
#include <Trade/Trade.mqh>

enum ENUM_WIN_LOSE { TRADE_RESULT_WIN, TRADE_RESULT_LOSE, TRADE_RESULT_ELSE };

class WrappedTrade : public CObject {
private:
  CTrade trade;
  string symbol;
  ulong magicNumber;
  int digits;

public:
  LotSizeManager *lotSizeManager;
  ExitLevelManager *exitLevelManager;
  WrappedTrade(string _symbol, ulong _magicNumber,
               LotSizeManager *_lotSizeManager,
               ExitLevelManager *_exitLevelManager) {
    symbol = _symbol;
    magicNumber = _magicNumber;
    trade = CTrade();
    trade.SetExpertMagicNumber(magicNumber);
    trade.LogLevel(LOG_LEVEL_ERRORS);
    // trade.SetAsyncMode(true);
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

    if (ret) {
      int error = GetLastError();
      if (error != 0) {
        printf("OrderSend Error : %d", error);
        printf("current bid: %f", SymbolInfoDouble(Symbol(), SYMBOL_BID));
        printf("current ask: %f", SymbolInfoDouble(Symbol(), SYMBOL_ASK));
      }
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

    if (ret) {
      int error = GetLastError();
      if (error != 0) {
        printf("OrderSend Error : %d", error);
        printf("current bid: %f", SymbolInfoDouble(Symbol(), SYMBOL_BID));
        printf("current ask: %f", SymbolInfoDouble(Symbol(), SYMBOL_ASK));
      }
    }
    return ret;
  }

  bool stopActiveBaseLong(double range) {
    double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT) * 10;
    double price = ask + range * point;

    return stopLong(price);
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

  bool stopActiveBaseShort(double range) {
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT) * 10;
    double price = bid - range * point;
    return stopShort(price);
  }

  bool activeLong() {
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    return activeLong(lotSizeManager.get(),
                      exitLevelManager.getSl(ask, POSITION_TYPE_BUY),
                      exitLevelManager.getTp(ask, POSITION_TYPE_BUY));
  }

  bool activeLong(const double lot) {
    double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    return activeLong(lot, exitLevelManager.getSl(ask, POSITION_TYPE_BUY),
                      exitLevelManager.getTp(ask, POSITION_TYPE_BUY));
  }

  bool activeLong(const double lot, const double sl, const double tp) {
    return trade.Buy(lot, symbol, 0, sl, tp, "Long");
  }

  bool activeShort() {
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    return activeShort(lotSizeManager.get(),
                       exitLevelManager.getSl(bid, POSITION_TYPE_SELL),
                       exitLevelManager.getTp(bid, POSITION_TYPE_SELL));
  }

  bool activeShort(const double lot) {
    double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    return activeShort(lot, exitLevelManager.getSl(bid, POSITION_TYPE_SELL),
                       exitLevelManager.getTp(bid, POSITION_TYPE_SELL));
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

  bool hasPendingLongLimitOrder() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        // 指値注文または逆指値注文かつ Magic Number が一致
        if ((type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP) &&
            magic == magicNumber) {
          return true;
        }
      }
    }
    return false; // 指値注文なし
  }

  bool hasPendingShortLimitOrder() {
    int totalOrders = OrdersTotal(); // 保留中の注文数を取得

    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i); // 注文のチケット番号を取得
      if (OrderSelect(ticket)) {
        ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        // 指値注文または逆指値注文かつ Magic Number が一致
        if ((type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP) &&
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
          Print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          Print(ticket, "DELETE!!!!!!!!!!!!!!!!!!!!!!!!");
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
          orderModify(ticket, lotSizeManager.get(), price,
                      exitLevelManager.getSl(price, positionType),
                      exitLevelManager.getTp(price, positionType),
                      ORDER_TIME_GTC, 0, OrderGetDouble(ORDER_PRICE_OPEN));
        }
      }
    }
  }

  void getAllPositionTickets(ulong &result[]) {
    int totalPositions = PositionsTotal();

    ulong tmp[] = {};
    for (int i = 0; i < totalPositions; i++) {
      ulong ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket)) {
        ulong magic = PositionGetInteger(POSITION_MAGIC);
        if (magic == magicNumber) {
          ArrayResize(tmp, ArraySize(tmp) + 1);
          tmp[ArraySize(tmp) - 1] = ticket;
        }
      }
    }
    ArrayCopy(result, tmp);
  }

  void getAllOrderTickets(ulong &result[]) {
    int totalOrders = OrdersTotal();

    ulong tmp[] = {};
    for (int i = 0; i < totalOrders; i++) {
      ulong ticket = OrderGetTicket(i);
      if (OrderSelect(ticket)) {
        ulong magic = OrderGetInteger(ORDER_MAGIC);
        if (magic == magicNumber) {
          ArrayResize(tmp, ArraySize(tmp) + 1);
          tmp[ArraySize(tmp) - 1] = ticket;
        }
      }
    }
    ArrayCopy(result, tmp);
  }

  bool orderModify(const ulong ticket, const double volume, const double price,
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

  void updateExitLevel(const ulong ticket) {}

  void updateAllExitLevel() {
    ulong tickets[];
    getAllOrderTickets(tickets);
    for (int i = 0; i < ArraySize(tickets); i++) {
      updateExitLevel(tickets[i]);
    }
  }

  ENUM_WIN_LOSE getTradeResult(const MqlTradeTransaction &trans,
                               const MqlTradeRequest &request,
                               const MqlTradeResult &result) {
    //--- 取引リクエストの実行結果
    ulong lastOrderID = trans.order;
    ENUM_ORDER_TYPE lastOrderType = trans.order_type;
    ENUM_ORDER_STATE lastOrderState = trans.order_state;
    //--- トランザクションが実行される取引シンボルの名称
    string trans_symbol = trans.symbol;
    //--- トランザクションの種類
    ENUM_TRADE_TRANSACTION_TYPE trans_type = trans.type;
    if (trans_type != TRADE_TRANSACTION_DEAL_ADD) {
      return TRADE_RESULT_ELSE;
    }

    ulong deal_ticket = trans.deal;
    if (HistoryDealSelect(deal_ticket)) {
      ulong dealMagic = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
      double deal_profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
      ulong deal_reason = HistoryDealGetInteger(deal_ticket, DEAL_REASON);
      if (dealMagic == magicNumber) {

        // ストップロスで決済された場合
        if (deal_profit < 0 && deal_reason == DEAL_REASON_SL) {
          return TRADE_RESULT_LOSE;
        }
        if (deal_profit > 0 && deal_reason == DEAL_REASON_TP) {
          return TRADE_RESULT_WIN;
        }
      }

      if (HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT) {
        ulong ticket = HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
        if (PositionSelectByTicket(ticket)) {
          long positionMagic = PositionGetInteger(POSITION_MAGIC);
          if (positionMagic == magicNumber) {
            // このポジションはこのEAによって開かれ、手動で決済された
            // ここに処理を記述
            if (deal_profit > 0) {
              return TRADE_RESULT_WIN;
            }
            if (deal_profit < 0) {
              return TRADE_RESULT_LOSE;
            }
          }
        }
      }
    };
    return TRADE_RESULT_ELSE;
  };

  bool isBreakEven(double plusPips = 0.0) {
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double targetProfit = plusPips * point * 10;

    double profit = 0;
    // 保有している全てのポジションを確認
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
      // ポジションを選択
      if (positionSelectByIndex(i)) {
        if (PositionGetInteger(POSITION_MAGIC) != magicNumber)
          continue;
        // ポジションの利益を取得
        profit += PositionGetDouble(POSITION_PROFIT);
      }
    }
    return profit >= targetProfit;
  }

  bool isFilledOrder(const MqlTradeTransaction &trans) {
    if (trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return false;
    if (!HistoryDealSelect(trans.deal))
      return false;

    ulong dealMagic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);

    return dealMagic == magicNumber &&
           (trans.order_type == ORDER_TYPE_BUY_STOP ||
            trans.order_type == ORDER_TYPE_SELL_STOP);
  }
};
