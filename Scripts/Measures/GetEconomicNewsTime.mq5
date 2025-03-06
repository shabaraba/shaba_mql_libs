//+------------------------------------------------------------------+
//| Economic News Time Retrieval for XAUUSD                          |
//+------------------------------------------------------------------+
void OnStart() {
  {
    // 書き出すCSVファイルのパス
    string file_name = "EconomicData.csv";
    int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV);
    // int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV | FILE_COMMON);

    if (file_handle == INVALID_HANDLE) {
      Print("Open a file failed: ", file_name);
      return;
    }

    // CSVファイルにヘッダーを書き込む
    FileWrite(file_handle, "日時", "国", "通貨", "イベント", "重要度");

    // 取得する期間を設定（例：過去1年間）
    datetime end_time = TimeCurrent();
    datetime start_time = end_time - PeriodSeconds(PERIOD_D1) * 365;
    string currency = "US";
    MqlCalendarValue eventData[];

    // 経済指標データを取得
    CalendarValueHistory(eventData, start_time, end_time, currency);

    if (ArraySize(eventData) > 0) {
        Print(ArraySize(eventData), " events were found.");
      for (int i = 0; i < ArraySize(eventData); i++) {
        MqlCalendarEvent event;
        if (CalendarEventById(eventData[i].event_id, event)) {
          MqlCalendarCountry country;
          if (CalendarCountryById(event.country_id, country)) {
            // データをCSVファイルに書き込む
            FileWrite(file_handle,
                      TimeToString(eventData[i].time, TIME_DATE | TIME_MINUTES),
                      country.code, country.currency, event.name,
                      EnumToString(event.importance));
          }
        }
      }
    } else {
      Print("There is no data.");
    }

    // ファイルを閉じる
    FileClose(file_handle);
    Print("Script Successful", file_name);

        /*
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
    */
  }
}
