typedef void (*PROCESS_FUNC)(void);

class WrappedSystem {
public:
  static void OnCandle(PROCESS_FUNC func);
  static void OnCandle(string symbol, ENUM_TIMEFRAMES period,
                       PROCESS_FUNC func);
  static void exitByBlowout(double lot);
  static int getJstHour();
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
  if (MQLInfoInteger(MQL_TESTER)) {
    MqlDateTime t;
    TimeToStruct(TimeCurrent(), t);
    t.hour = 22;
    t.min = 30;
    t.sec = 0;
    datetime forTest[] = {StructToTime(t)};

    ArrayCopy(result, forTest);
    Print("For Tester");
    return;
  }

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
