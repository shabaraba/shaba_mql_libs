typedef void (*PROCESS_FUNC)(void);
enum ENUM_WIN_LOSE { TRADE_RESULT_WIN, TRADE_RESULT_LOSE, TRADE_RESULT_ELSE };

class WrappedSystem {
public:
  static void OnCandle(PROCESS_FUNC func);
  static void OnCandle(string symbol, ENUM_TIMEFRAMES period,
                       PROCESS_FUNC func);
  static ENUM_WIN_LOSE getTradeResult(const MqlTradeTransaction &trans,
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
    double deal_profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
    ulong deal_reason = HistoryDealGetInteger(deal_ticket, DEAL_REASON);

    // ストップロスで決済された場合
    if (deal_profit < 0 && deal_reason == DEAL_REASON_SL) {
      return TRADE_RESULT_LOSE;
    }
    if (deal_profit > 0 && deal_reason == DEAL_REASON_TP) {
      return TRADE_RESULT_WIN;
    }
    // 取引が成功したか確認
    if (HistoryDealSelect(deal_ticket)) {
      ulong order_ticket = HistoryDealGetInteger(
          deal_ticket, DEAL_ORDER); // 対応するオーダーのチケット
      ulong position_id =
          HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID); // ポジションID
      double profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT); // 損益
      if (profit > 0) {
        return TRADE_RESULT_WIN;
      }
      if (profit < 0) {
        return TRADE_RESULT_LOSE;
      }
    };
    return TRADE_RESULT_ELSE;
  };
};

void WrappedSystem::OnCandle(PROCESS_FUNC func) {
  WrappedSystem::OnCandle(_Symbol, PERIOD_CURRENT, func);
};

void WrappedSystem::OnCandle(string symbol, ENUM_TIMEFRAMES period,
                             PROCESS_FUNC func) {
  datetime currentDatetime = iTime(symbol, period, 1);
  static datetime lastDatetime = currentDatetime;

  if (lastDatetime == currentDatetime) {
    return;
  }

  lastDatetime = currentDatetime;
  func();
};
