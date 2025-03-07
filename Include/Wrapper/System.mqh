#include <Files/File.mqh>
#include <Files/FileTxt.mqh>

CFile cfile;
CFileTxt ctext;

typedef void (*PROCESS_FUNC)(void);

struct EconomicEvent {
  datetime dateTime;
  string name;
};

class WrappedSystem {
private:
  static void getEconomicNewsTimeForTester(const string countryCode,
                                           datetime from, datetime to,
                                           EconomicEvent &result[]);

public:
  static void OnCandle(PROCESS_FUNC func);
  static void OnCandle(string symbol, ENUM_TIMEFRAMES period,
                       PROCESS_FUNC func);
  static void exitByBlowout(double lot);
  static int getJstHour();
  static void getEconomicNewsTime(const string countryCode, datetime from,
                                  datetime to, EconomicEvent &result[]);
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
};

void WrappedSystem::getEconomicNewsTimeForTester(const string countryCode,
                                                 datetime from, datetime to,
                                                 EconomicEvent &result[]) {
  Print("For Tester");
  cfile.SetCommon(true);
  //--- ファイル名の設定
  string fileName = "EconomicData.csv";

  //--- ファイルを開く（読み取り専用、CSV形式、ANSIエンコーディング）
  int file_handle = cfile.Open(fileName, FILE_READ | FILE_CSV | FILE_ANSI);
  if (file_handle == INVALID_HANDLE) {
    PrintFormat("fail open failed: %d", GetLastError());
    return;
  }

  datetime current = TimeTradeServer();
  //--- ファイルの終端まで読み込む
  while (!FileIsEnding(file_handle)) {
    //--- 1行読み込み
    datetime date_time = FileReadDatetime(file_handle);
    string country = FileReadString(file_handle);
    string currency = FileReadString(file_handle);
    string eventName = FileReadString(file_handle);
    string importance = FileReadString(file_handle);
    if (importance == "CALENDAR_IMPORTANCE_HIGH" && country == countryCode &&
        date_time > from && date_time <= to) {
      EconomicEvent event;
      event.dateTime = date_time;
      event.name = eventName;
      ArrayResize(result, ArraySize(result) + 1);
      result[ArraySize(result) - 1] = event;
    }
    if (date_time - current > 24 * 3600)
      break;
  }
  cfile.Close();
  return;
};

void WrappedSystem::getEconomicNewsTime(const string countryCode, datetime from,
                                        datetime to, EconomicEvent &result[]) {
  ArrayResize(result, 0);
  if (MQLInfoInteger(MQL_TESTER)) {
    getEconomicNewsTimeForTester(countryCode, from, to, result);
  } else {
    MqlCalendarValue eventData[];

    Print("From: ", from, " to: ", to);

    if (CalendarValueHistory(eventData, from, to, countryCode)) {
      PrintFormat("Received event values for country_code=%s: %d", countryCode,
                  ArraySize(eventData));

      if (ArraySize(eventData) > 0) {
        Print(ArraySize(eventData), " events were found.");
        for (int i = 0; i < ArraySize(eventData); i++) {
          MqlCalendarEvent calendarEvent;
          if (!CalendarEventById(eventData[i].event_id, calendarEvent))
            continue;
          MqlCalendarCountry country;
          if (!CalendarCountryById(calendarEvent.country_id, country))
            continue;
          if (calendarEvent.importance != CALENDAR_IMPORTANCE_HIGH)
            continue;
          EconomicEvent event;
          event.dateTime = eventData[i].time;
          event.name = calendarEvent.name;
          ArrayResize(result, ArraySize(result) + 1);
          result[ArraySize(result) - 1] = event;
        }
      } else {
        PrintFormat("Error!Failed to receive events for country_code=%s", "US");
        PrintFormat("Error code: %d", GetLastError());
      }
    }
  }

  datetime _tmp = NULL;
  for (int i = ArraySize(result) - 1; i >= 0; i--) {
    if (_tmp == result[i].dateTime) {
      result[i + 1].name += ", " + result[i].name;
      ArrayRemove(result, i, 1);
      continue;
    }
    _tmp = result[i].dateTime;
  }
};
