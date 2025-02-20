//+------------------------------------------------------------------+
//| Economic News Time Retrieval for XAUUSD                          |
//+------------------------------------------------------------------+
void OnStart() {
  {
    //--- EUイベント値を取得する
    MqlCalendarValue values[];
    //--- イベントを取得する期間の境界を設定する
    // 今日の0時
    datetime today_midnight;
    MqlDateTime today_struct;
    TimeToStruct(TimeCurrent(), today_struct); // 現在の時刻をMqlDateTimeに変換

    // 日付の部分だけ今日の0時に設定
    today_struct.hour = 0;
    today_struct.min = 0;
    today_struct.sec = 0;

    // 今日の0時のdatetimeを取得
    today_midnight = StructToTime(today_struct);

    // 翌日の23時
    datetime tomorrow_23h;
    today_struct.hour = 23; // 23時
    today_struct.min = 0;
    today_struct.sec = 0;

    // 翌日の23時のdatetimeを取得
    tomorrow_23h = StructToTime(today_struct);

    // 結果を表示
    Print("今日の0時: ", TimeToString(today_midnight,
                                      TIME_DATE | TIME_MINUTES | TIME_SECONDS));
    Print("翌日の23時: ",
          TimeToString(tomorrow_23h, TIME_DATE | TIME_MINUTES | TIME_SECONDS));
    datetime date_from = today_midnight;
    datetime date_to = tomorrow_23h;
    if (CalendarValueHistory(values, date_from, date_to, "US")) {
      PrintFormat("Received event values for country_code=%s: %d", "US",
                  ArraySize(values));
      //--- 操作ログに出力する配列サイズを減らす
      ArrayResize(values, 10);
      //--- 操作ログにイベント値を表示する
      ArrayPrint(values);
      for (int i = 0; i < 10; i++) {
        MqlDateTime eventStruct;

        TimeToStruct(values[i].time, eventStruct);
        eventStruct.hour += 9;
        if (eventStruct.hour >= 24) {
          eventStruct.day += 1;
          eventStruct.hour = 24 - eventStruct.hour;
        }
        datetime _eventTime = StructToTime(eventStruct);
        Print(_eventTime);
      }
    } else {
      PrintFormat("Error!Failed to receive events for country_code=%s", "US");
      PrintFormat("Error code: %d", GetLastError());
    }
    //---
  }
}
