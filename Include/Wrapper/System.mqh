typedef void (*PROCESS_FUNC)(void);
enum ENUM_WIN_LOSE { TRADE_RESULT_WIN, TRADE_RESULT_LOSE, TRADE_RESULT_ELSE };

class WrappedSystem {
public:
  static void OnCandle(PROCESS_FUNC func);
  static void OnCandle(string symbol, ENUM_TIMEFRAMES period,
                       PROCESS_FUNC func);
  static void exitByBlowout(double lot);
  static int getJstHour();
  static ENUM_WIN_LOSE getTradeResult(const MqlTradeTransaction &trans,
                                      const MqlTradeRequest &request,
                                      const MqlTradeResult &result);
  static void getEconomicNewsTime(const string countryCode, datetime &result[]);
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

ENUM_WIN_LOSE WrappedSystem::getTradeResult(const MqlTradeTransaction &trans,
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
int WrappedSystem::getJstHour() {
  datetime currentDatetime = TimeCurrent(); // 現在のサーバー時間 (UTC)
  MqlDateTime tm;
  TimeToStruct(currentDatetime, tm);
  int jstHour = tm.hour + 9;
  if (jstHour >= 24)
    jstHour -= 24; // 24時超えたら補正
  return jstHour;
}
void WrappedSystem::exitByBlowout(double lot) {
  double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN); // 最小ロット
  MqlTick tick = {};
  //--- 銘柄ごとの最新価格を取得する
  if (!SymbolInfoTick(_Symbol, tick)) {
    Print("SymbolInfoTick() failed. Error ", GetLastError());
    return;
  }
  double price = tick.bid;
  double margin = EMPTY_VALUE;
  ResetLastError();
  if (!OrderCalcMargin(ORDER_TYPE_SELL, _Symbol, lot, price, margin)) {
    Print("OrderCalcMargin() failed. Error ", GetLastError());
    return;
  }
  double equity = AccountInfoDouble(ACCOUNT_EQUITY); // 余剰証拠金（エクイティ）
  // Print("lot: ", lot, " margin: ", margin);

  if (equity < margin) {
    Print("no money...blowout...");
    ExpertRemove(); // EAを停止
  }
}

void WrappedSystem::getEconomicNewsTime(const string countryCode,
                                        datetime &result[]) {
  MqlCalendarValue values[];
  datetime tmp[];
  datetime from = TimeCurrent();
  datetime to = from + 3600 * 24;

  Print("From: ", from, " to: ", to);
  ArrayResize(tmp, 0);

  if (CalendarValueHistory(values, from, to, "EU")) {
    PrintFormat("Received event values for country_code=%s: %d", "US",
                ArraySize(values));
    ArrayResize(values, 10);
    ArrayPrint(values);
    for (int i = 0; i < ArraySize(values); i++) {
      MqlDateTime eventStruct;

      TimeToStruct(values[i].time, eventStruct);
      eventStruct.hour += 9;
      if (eventStruct.hour >= 24) {
        eventStruct.day += 1;
        eventStruct.hour = 24 - eventStruct.hour;
      }
      datetime _eventTime = StructToTime(eventStruct);
      if (_eventTime == 0)
        continue;
      bool duplicated = false;
      for (int j = 0; j < ArraySize(tmp); j++) {
        if (tmp[j] == _eventTime) {
          duplicated = true;
          break;
        }
      }
      if (duplicated)
        continue;
      ArrayResize(tmp, ArraySize(tmp) + 1);
      tmp[ArraySize(tmp) - 1] = _eventTime;
    }
  } else {
    PrintFormat("Error!Failed to receive events for country_code=%s", "US");
    PrintFormat("Error code: %d", GetLastError());
  }
  ArrayCopy(result, tmp);
}
